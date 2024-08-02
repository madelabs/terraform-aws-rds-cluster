data "aws_rds_engine_version" "family" {
  engine  = "aurora-postgresql"
  version = var.postgres_version
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
  master_username                     = var.db_master_user
  master_password                     = local.db_password
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
  kms_key_id                          = var.create_kms_key ? aws_kms_key.cluster_storage_key[0].arn : null
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  tags                                = var.cluster_tags
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
  for_each                     = { for idx, instance in local.instances : idx => instance }
  identifier                   = "${local.cluster_identifier}-${each.value.instance_number}${each.value.instance_name != "" ? "-${each.value.instance_name}" : ""}"
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
  tags = {
    for tag in var.instance_specific_tags :
    tag.tag_key => tag.tag_value
    if tag.instance_number == each.key + 1
  }

  lifecycle {
    precondition {
      condition     = var.database_instance_count >= local.tags_max_instance_number
      error_message = "Instance number attribute on instance_specific_tags variable cannot be greater than database_instance_count."
    }
  }
}

locals {
  tags_instance_numbers    = [for tag in var.instance_specific_tags : tag.instance_number]
  tags_max_instance_number = length(local.tags_instance_numbers) == 0 ? 0 : max(local.tags_instance_numbers...)
  instances = [for i in range(var.database_instance_count) : {
    instance_number = i + 1
    instance_tags   = [for tag in var.instance_specific_tags : tag if tag.instance_number == i + 1]
    instance_name = try(
      (tolist([for tag in var.instance_specific_tags : tag.tag_value if tag.instance_number == i + 1 && tag.tag_key == "instance_name"])[0]),
      ""
    )
  }]
}


