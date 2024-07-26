resource "aws_secretsmanager_secret" "aurora_access_data" {
  name                    = "${var.env}-${var.cluster_suffix_name}-master-account-pgSQL"
  recovery_window_in_days = var.secret_deletion_window_in_days
}

resource "aws_secretsmanager_secret_version" "aurora_access_data_version" {
  secret_id = aws_secretsmanager_secret.aurora_access_data.id
  secret_string = jsonencode({
    username = var.db_master_user,
    password = local.db_password,
    host     = aws_rds_cluster.primary.endpoint
    port     = var.db_port,
    dbname   = var.database_name
  })

}

data "aws_secretsmanager_secret_version" "aurora_password" {
  count     = var.generate_password == true ? 0 : 1
  secret_id = var.secret_id
}

locals {
  db_password = var.generate_password == true ? random_password.aurora_password[0].result : data.aws_secretsmanager_secret_version.aurora_password[0].secret_string
}
