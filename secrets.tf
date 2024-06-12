# resource "aws_secretsmanager_secret_version" "secret_value" {
#   secret_id = var.secret_id
#   secret_string = jsonencode({
#     username = var.db_root_user,
#     password = random_password.aurora.result,
#     host     = aws_rds_cluster.primary.endpoint
#     port     = var.db_port,
#     dbname   = "postgres"
#   })
#   lifecycle {
#     ignore_changes = [
#       secret_string
#     ]
#   }
# }