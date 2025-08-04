resource "aws_iam_role_policy" "bedrock_access_policy" {
  role   = aws_iam_role.scenario_generation_service_account.id
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
