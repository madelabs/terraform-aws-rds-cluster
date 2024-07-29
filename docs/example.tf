# This file has two examples showing some different ways to utilize the module
# Example 1 is when you don't want to specify a password. In this case, the module is going to generate a random password for the cluster, and you can access it using the ouput secret that is created
# Example 2 is when you want to specify a password. In this case, it has to be done through a Secrets Manager secret. You create the secret, add the desired password there, and provide secret_id variable, so the module can access it.

#Example 1
module "example_project" {
  source                              = "madelabs/rds-cluster/aws"
  version                             = "0.0.5"
  generate_password                   = true
  env                                 = "dev"
  aurora_security_group_id            = "sg-0fb4ba8549e60d174"
  instance_class                      = "db.t3.medium"
  subnet_group_name                   = "default"
  publicly_accessible                 = true
  iam_database_authentication_enabled = true
  cluster_suffix_name                 = "aurorapg-2"
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "dev-aurorapg-1-snapshot"
  db_master_user                      = "root"
  db_port                             = "5432"
  storage_encrypted                   = true
  create_kms_key                      = true
  secret_deletion_window_in_days      = 0
  cluster_parameter_group = [
    {
      name         = "rds.force_autovacuum_logging_level"
      value        = "warning"
      apply_method = "immediate"
    }
  ]
  db_instance_parameter_group = [
    {
      name         = "shared_preload_libraries"
      value        = "auto_explain,pg_stat_statements,pg_hint_plan,pgaudit"
      apply_method = "pending-reboot"
    },
    {
      name         = "log_lock_waits"
      value        = 1
      apply_method = "immediate"
  }]
}

##-----------------------------------------------------------------------------------------##

#Example 2
variable "password" {
  type        = string
  description = "Master user password value."
}

resource "aws_secretsmanager_secret" "aurora_cluster_password" {
  name                    = "database-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "initial_secret" {
  secret_id     = aws_secretsmanager_secret.aurora_cluster_password.id
  secret_string = var.password
}

module "example_project_2" {
  source                              = "madelabs/rds-cluster/aws"
  version                             = "0.0.5"
  generate_password                   = false
  env                                 = "dev"
  aurora_security_group_id            = "sg-0fb4ba8549e60d174"
  instance_class                      = "db.t3.medium"
  subnet_group_name                   = "default"
  publicly_accessible                 = true
  iam_database_authentication_enabled = true
  cluster_suffix_name                 = "aurorapg-2"
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "dev-aurorapg-1-snapshot"
  db_master_user                      = "root"
  db_port                             = "5432"
  storage_encrypted                   = true
  create_kms_key                      = true
  secret_deletion_window_in_days      = 0
  secret_id                           = aws_secretsmanager_secret.aurora_cluster_password.id
  cluster_parameter_group = [
    {
      name         = "rds.force_autovacuum_logging_level"
      value        = "warning"
      apply_method = "immediate"
    }
  ]
  db_instance_parameter_group = [
    {
      name         = "shared_preload_libraries"
      value        = "auto_explain,pg_stat_statements,pg_hint_plan,pgaudit"
      apply_method = "pending-reboot"
    },
    {
      name         = "log_lock_waits"
      value        = 1
      apply_method = "immediate"
  }]
}


