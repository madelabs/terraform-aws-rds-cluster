module "example_project" {
  source  = "madelabs/rds-cluster/aws"
  version = "0.0.4"

  env                                 = "dev"
  aurora_security_group_id            = "sg-275a5d69"
  instance_class                      = "db.t3.medium"
  subnet_group_name                   = "rds"
  publicly_accessible                 = false
  iam_database_authentication_enabled = true
  cluster_suffix_name                 = "aurorapg-1"
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "dev-aurorapg-1"
  secret_id                           = aws_secretsmanager_secret.aurora_root_secret.id
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

resource "aws_secretsmanager_secret" "aurora_root_secret" {
  name = "your secret name"
}
