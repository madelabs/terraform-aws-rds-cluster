output "rds_cluster_endpoint" {
  value = aws_rds_cluster.primary.endpoint
}

output "rds_cluster_arn" {
  value = aws_rds_cluster.primary.arn
}

output "rds_cluster_resource_id" {
  value = aws_rds_cluster.primary.cluster_resource_id
}

output "database_port" {
  value = var.db_port
}
