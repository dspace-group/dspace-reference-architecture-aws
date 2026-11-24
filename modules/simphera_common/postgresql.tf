resource "aws_db_instance" "database" {
  apply_immediately                   = var.database.postgresqlApplyImmediately
  allocated_storage                   = var.database.postgresqlStorage
  max_allocated_storage               = var.database.postgresqlMaxStorage
  auto_minor_version_upgrade          = true # [RDS.13] RDS automatic minor version upgrades should be enabled
  allow_major_version_upgrade         = true
  engine                              = "postgres"
  engine_version                      = var.database.postgresqlVersion
  instance_class                      = var.database.db_instance_type
  identifier                          = local.database_identifier
  db_name                             = var.database.db_name
  username                            = "dbuser"
  password                            = local.secrets["postgresql_password"]
  multi_az                            = var.database.multi_az # [RDS.5] RDS DB instances should be configured with multiple Availability Zones
  enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_enhanced_monitoring.arn # [RDS.9] Database logging should be enabled
  deletion_protection                 = var.database.enable_deletion_protection  # [RDS.7] RDS clusters should have deletion protection enabled
  skip_final_snapshot                 = !var.database.enable_deletion_protection
  final_snapshot_identifier           = "${local.database_identifier}-final-snapshot"
  iam_database_authentication_enabled = true # [RDS.10] IAM authentication should be configured for RDS instances
  copy_tags_to_snapshot               = true
  storage_encrypted                   = true # [RDS.3] RDS DB instances should have encryption at rest enabled
  db_subnet_group_name                = aws_db_subnet_group.database.name
  vpc_security_group_ids              = [aws_security_group.database.id]
  tags                                = var.tags
  depends_on = [
    aws_cloudwatch_log_group.database
  ]
  timeouts {
    create = "2h"
    delete = "2h"
    update = "2h"
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "${local.database_identifier}-subnet-group"
  subnet_ids = var.database.private_subnets_ids
  tags       = var.tags
}

resource "aws_security_group" "database" {
  name                   = "${local.database_identifier}-sg"
  description            = "Security group for ${local.database_identifier} RDS instance"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = var.tags

}

resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  security_group_id = aws_security_group.database.id
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
  description       = "Allow access from within VPC"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name        = "${local.database_identifier}-rds-enhanced-monitoring"
  description = "AWS AM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "monitoring.rds.amazonaws.com"
            ]
          },
          "Action" : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )

  tags = var.tags
}

# [RDS.6] Enhanced monitoring should be configured for RDS DB instances and clusters
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_log_group" "database" {
  name              = "/aws/rds/instance/${local.database_identifier}/postgresql" # CAUTION: the name is predetermined by AWS RDS. Do not change it. Otherwise AWS will create a new log group without retention and encryption.
  retention_in_days = var.database.cloudwatch_retention
  kms_key_id        = var.kms_cloudwatch_key_arn
  tags              = var.tags
}
