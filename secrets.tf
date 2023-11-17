resource "aws_secretsmanager_secret" "aurora_root_secret" {
  name = "${aws_rds_cluster.primary.cluster_identifier}-${var.secrets_manager_suffix_name}"
}

resource "aws_secretsmanager_secret_version" "initial_secret" {
  secret_id = aws_secretsmanager_secret.aurora_root_secret.id
  secret_string = jsonencode({
    username = var.db_root_user,
    password = random_password.aurora.result,
    host     = aws_rds_cluster.primary.endpoint
    port     = var.db_port,
    dbname   = "postgres"
  })
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}