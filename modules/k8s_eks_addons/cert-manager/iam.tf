
locals {
  oidc_path = regex("oidc-provider/(.*)", var.oidc_arn)[0]
}

resource "aws_iam_role" "certmanager_irsa" {
  name = "${var.infrastructurename}-certmanager"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_path}:sub" : "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      }
    ]
  })

  tags = var.tags

}

resource "aws_iam_policy" "certmanager_irsa_policy" {
  name = "${var.infrastructurename}-certmanager-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : "arn:aws:route53:::hostedzone/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZonesByName",
          "Resource" : "*"
        }
      ]
    }
  )
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "certmanager_attachment" {
  role       = aws_iam_role.certmanager_irsa.name
  policy_arn = aws_iam_policy.certmanager_irsa_policy.arn
}
