resource "aws_iam_role_policy" "bedrock_access_policy" {
  role   = aws_iam_role.scenario_generation_opensearch_bedrock.id
  name   = "${local.instancename}-bedrock-access-policy"
  policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "bedrock:*",
            "Resource" : "*"
        }
    ]
    }
    EOF
}
