locals {
  cluster_identifier = "${var.env}-${var.cluster_suffix_name}"
  supported_engine   = "aurora-postgresql"
  logs_set = compact([
    var.enable_postgresql_log ? "postgresql" : ""
  ])
  db_password = var.generate_password == true ? random_password.aurora_password[0].result : data.aws_secretsmanager_secret_version.aurora_password[0].secret_string
  db_name     = aws_rds_cluster.primary.database_name == null ? "postgres" : aws_rds_cluster.primary.database_name
}
