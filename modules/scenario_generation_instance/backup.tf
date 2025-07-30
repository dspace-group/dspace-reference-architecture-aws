resource "aws_backup_vault" "scenario_generation" {
  count = var.enable_backup_service ? 1 : 0
  name  = local.backup_vault_name
}

resource "aws_backup_plan" "scenario_generation" {
  count = var.enable_backup_service ? 1 : 0
  name  = "${local.instancename}-backup-plan"

  rule {
    rule_name                = "${local.instancename}-backup-rule"
    target_vault_name        = aws_backup_vault.scenario_generation_backup_vault[0].name
    recovery_point_tags      = var.tags
    enable_continuous_backup = true

    lifecycle {
      delete_after = var.backup_retention
    }
  }
  tags = var.tags
}

resource "aws_backup_selection" "scenario_generation_rds" {
  count        = var.enable_backup_service ? 1 : 0
  name         = "${local.instancename}-rds"
  iam_role_arn = aws_iam_role.scenario_generation_backup_iam_role[0].arn
  plan_id      = aws_backup_plan.scenario_generation_backup_plan[0].id
  resources    = local.backup_resources
}

resource "aws_iam_role" "scenario_generation_backup_role" {
  count              = var.enable_backup_service ? 1 : 0
  name               = "${var.name}-backup-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "scenario_generation_backup_policy_rds" {
  count      = var.enable_backup_service ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.scenario_generation_backup_iam_role[0].name
}
