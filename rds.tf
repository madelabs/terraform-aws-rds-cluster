data "aws_rds_engine_version" "family" {
  engine  = "aurora-postgresql"
  version = var.postgres_version
}

resource "random_password" "aurora" {
  length  = var.password_length
  special = var.password_include_special_character
}

# Cluster Configuration
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group_p" {
  name_prefix = "${local.cluster_identifier}-cluster-"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "Parameter group for the cluster ${local.cluster_identifier}"

  dynamic "parameter" {
    for_each = var.cluster_parameter_group
    iterator = pblock

    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier                  = local.cluster_identifier
  engine                              = local.supported_engine
  engine_version                      = var.postgres_version
  db_subnet_group_name                = var.subnet_group_name
  port                                = var.db_port
  database_name                       = var.database_name
  master_username                     = var.db_root_user
  master_password                     = random_password.aurora.result
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.id
  db_instance_parameter_group_name    = aws_db_parameter_group.aurora_db_parameter_group_p.id
  backup_retention_period             = var.backup_retention_days
  apply_immediately                   = var.apply_changes_immediately
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.final_snapshot_identifier
  snapshot_identifier                 = var.snapshot_identifier
  vpc_security_group_ids              = [var.aurora_security_group_id]
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = local.logs_set
  storage_encrypted                   = var.storage_encrypted
  deletion_protection                 = var.deletion_protection
  kms_key_id                          = var.create_kms_key ? aws_kms_key.cluster_storage_key.arn : null

  depends_on = [aws_kms_key.cluster_storage_key]

  lifecycle {
    ignore_changes = [
      replication_source_identifier
    ]
  }
}

# Instance Configuration
resource "aws_db_parameter_group" "aurora_db_parameter_group_p" {
  name_prefix = "${local.cluster_identifier}-db-"
  family      = data.aws_rds_engine_version.family.parameter_group_family
  description = "Parameter group for the instances of the cluster ${local.cluster_identifier}."

  dynamic "parameter" {
    for_each = var.db_instance_parameter_group
    iterator = pblock

    content {
      name         = pblock.value.name
      value        = pblock.value.value
      apply_method = pblock.value.apply_method
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "primary" {
  publicly_accessible          = var.publicly_accessible
  count                        = var.database_instance_count
  identifier                   = "${local.cluster_identifier}-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.primary.id
  engine                       = aws_rds_cluster.primary.engine
  engine_version               = var.postgres_version
  instance_class               = var.instance_class
  db_subnet_group_name         = var.subnet_group_name
  db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group_p.id
  performance_insights_enabled = var.performance_insights_enabled
  apply_immediately            = var.apply_changes_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  monitoring_interval          = var.monitoring_interval
}
