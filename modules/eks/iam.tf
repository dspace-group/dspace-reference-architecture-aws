resource "aws_iam_role" "cluster_role" {
  name                  = local.cluster_iam_role_name
  path                  = null
  description           = "AWS IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations."
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary  = null
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy" "cluster_role_cloudwatch_log_group" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name = local.cluster_iam_role_name
  role = aws_iam_role.cluster_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup"]
        Effect   = "Deny"
        Resource = aws_cloudwatch_log_group.log_group[0].arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_role" {
  for_each = toset([
    "${local.policy_arn_prefix}/AmazonEKSClusterPolicy",
    "${local.policy_arn_prefix}/AmazonEKSVPCResourceController",
  ])
  policy_arn = each.value
  role       = aws_iam_role.cluster_role.name
}
