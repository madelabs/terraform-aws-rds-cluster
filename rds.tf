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
  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  apply_immediately                   = var.apply_changes_immediately
  availability_zones                  = var.availability_zones
  backup_retention_period             = var.backup_retention_days
  cluster_identifier                  = local.cluster_identifier
  database_name                       = var.database_name
  db_cluster_instance_class           = var.db_cluster_instance_class
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.id
  db_instance_parameter_group_name    = aws_db_parameter_group.aurora_db_parameter_group_p.id
  db_subnet_group_name                = var.subnet_group_name
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = local.logs_set
  engine                              = local.supported_engine
  engine_version                      = var.postgres_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iops                                = var.iops
  kms_key_id                          = var.create_kms_key ? aws_kms_key.cluster_storage_key[0].arn : null
  master_password                     = local.db_password
  master_username                     = var.db_master_user
  port                                = var.db_port
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = var.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  tags                                = var.cluster_tags
  vpc_security_group_ids              = [var.aurora_security_group_id]
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
  publicly_accessible                   = var.publicly_accessible
  for_each                              = { for idx, instance in local.instances : idx => instance }
  identifier                            = "${local.cluster_identifier}-${each.value.instance_number}${each.value.instance_name != "" ? "-${each.value.instance_name}" : ""}"
  cluster_identifier                    = aws_rds_cluster.primary.id
  engine                                = aws_rds_cluster.primary.engine
  engine_version                        = var.postgres_version
  instance_class                        = var.instance_class
  db_subnet_group_name                  = var.subnet_group_name
  db_parameter_group_name               = aws_db_parameter_group.aurora_db_parameter_group_p.id
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled && var.create_kms_key ? aws_kms_key.cluster_storage_key[0].arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period_in_days : null
  apply_immediately                     = var.apply_changes_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  preferred_maintenance_window          = var.preferred_maintenance_window
  availability_zone                     = each.value.instance_az
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
    instance_az = var.availability_zones[i % length(var.availability_zones)]
  }]
}
