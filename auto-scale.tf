resource "aws_appautoscaling_target" "aurora_scaling_target" {
  count              = var.enable_auto_scale ? 1 : 0
  service_namespace  = "rds"
  resource_id        = "cluster:${aws_rds_cluster.primary.id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  min_capacity       = var.auto_scale_min_capacity
  max_capacity       = var.auto_scale_max_capacity
}

resource "aws_appautoscaling_policy" "aurora_scaling_policy" {
  count              = var.enable_auto_scale ? 1 : 0
  name               = "${var.auto_scale_metric} policy"
  service_namespace  = "rds"
  resource_id        = aws_appautoscaling_target.aurora_scaling_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.aurora_scaling_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.auto_scale_metric
    }
    target_value       = var.target_value_for_metric
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}
