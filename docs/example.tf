#Create a random password
resource "random_password" "aurora_password" {
  length  = 10
  special = true
}

#Create a secret to store the password
resource "aws_secretsmanager_secret" "aurora_root_secret" {
  name                    = "aurora-secret"
  recovery_window_in_days = 7
}

#Store the secret in the secret
resource "aws_secretsmanager_secret_version" "initial_secret" {
  secret_id     = aws_secretsmanager_secret.aurora_root_secret.id
  secret_string = random_password.aurora_password.result
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

#Call this module referencing the secret-id
module "example_project" {
  source  = "madelabs/rds-cluster/aws"
  version = "0.0.4"

  env                                 = "dev"
  aurora_security_group_id            = "sg-0fb4ba8549e60d174"
  instance_class                      = "db.t3.medium"
  subnet_group_name                   = "default"
  publicly_accessible                 = true
  iam_database_authentication_enabled = true
  cluster_suffix_name                 = "aurorapg-1"
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "dev-aurorapg-1-snapshot"
  secret_id                           = aws_secretsmanager_secret.aurora_root_secret.id
  db_master_user                      = "root"
  db_port                             = "5432"
  storage_encrypted                   = true
  create_kms_key                      = true
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
  depends_on = [aws_secretsmanager_secret_version.initial_secret]
}


