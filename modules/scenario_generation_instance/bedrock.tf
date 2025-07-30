resource "aws_iam_role" "bedrock_iam_role" {
  name        = "${local.instancename}-bedrock-role"
  description = "IAM role for the Bedrock service account"
  tags        = var.tags
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer}:sub" : "system:serviceaccount:${var.k8s_namespace}:${local.bedrock_serviceaccount}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_access_policy" {
  role   = aws_iam_role.bedrock_iam_role.id
  name   = "${local.instancename}-bedrock-access-policy"
  policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "bedrock:*",
            "Resource": [
                "arn:aws:bedrock:${var.bedrock_region}:${var.aws_context.caller_identity_account_id}:inference-profile/eu.anthropic.claude-3-7-sonnet-20250219-v1:0",
                "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0",
                "arn:aws:bedrock:${var.bedrock_region}:${var.aws_context.caller_identity_account_id}:inference-profile/eu.anthropic.claude-3-5-sonnet-20240620-v1:0",
                "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0",
                "arn:aws:bedrock:*::foundation-model/amazon.titan-embed-text-v2:0"
            ]
        }
    ]
    }
    EOF
}

resource "kubernetes_service_account" "bedrock_service_account" {
  metadata {
    name      = local.bedrock_serviceaccount
    namespace = kubernetes_namespace.scenario_generation.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.bedrock_iam_role.arn
    }
  }
  automount_service_account_token = false
}
