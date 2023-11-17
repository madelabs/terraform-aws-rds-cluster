locals {
  cluster_identifier = "${var.env}-${var.cluster_suffix_name}"
  supported_engine   = "aurora-postgresql"
  logs_set = compact([
    var.enable_postgresql_log ? "postgresql" : ""
  ])
}
