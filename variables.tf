variable "env" {
  type        = string
  description = "Name of the environment where this infrastructure is going to be deployed, such as 'dev', 'prod' or whatever name you use. This will be a name prefix for the created resources."
}

variable "db_port" {
  type        = string
  description = "Port where the database will be available for connections."
  default     = "5432"
}

variable "postgres_version" {
  type        = string
  description = "Postgres version to run."
  default     = "13.8"
}

variable "backup_retention_days" {
  type        = number
  description = "How many days will backup be kept."
  default     = 7
}

variable "instance_class" {
  type        = string
  description = "Database Instance Class."
}

variable "subnet_group_name" {
  type        = string
  description = "Name of subnet group, where the database will be connected. It must be a preexisting subnet group name on the target account."
}

variable "cluster_suffix_name" {
  type        = string
  description = "This will be part of the cluster name and cluster instances, along with env variable value. If env='foo' and cluster_identifier is 'bar', cluster name will be 'foo-bar'."
  default     = "aurorapg"
}

variable "database_instance_count" {
  type        = number
  description = "Number of database instances to be created in the cluster."
  default     = 1
}

variable "database_name" {
  type        = string
  description = "If provided, a database with this name will automatically be created on cluster creation."
  default     = null
}

variable "apply_changes_immediately" {
  type        = bool
  description = "Changes to an RDS Cluster can occur when you manually change a parameter, such as port, and are reflected in the next maintenance window. You can use the apply_changes_immediately flag to instruct the service to apply the change immediately."
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier."
  default     = false
}

variable "final_snapshot_identifier" {
  type        = string
  description = "Name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
}

variable "snapshot_identifier" {
  type        = string
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot."
  default     = null
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights is enabled or not."
  default     = false
}

variable "enable_postgresql_log" {
  type        = bool
  description = "Whether postgresql logs will be enable for the created cluster."
  default     = false
}

#Security Variables
# variable "password_length" {
#   type        = number
#   description = "Length of the random password to be generated for the cluster."
#   default     = 10
# }

# variable "password_include_special_character" {
#   type        = bool
#   description = "Wheter the generated password should have special characters in it."
#   default     = false
# }

variable "db_root_password" {
  type = string
  description = "value"
  sensitive   = true
}

variable "iam_database_authentication_enabled" {
  type        = bool
  description = "Wether IAM authentication will be enabled for the created cluster."
  default     = false
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the database will be publicly accessible. If true, the VPC needs to have an Internet Gateway attached to it."
  default     = false
}

# variable "secret_id" {
#   type        = string
#   description = "The aws_secretsmanager_secret id where the password should be stored."
# }

variable "db_root_user" {
  type        = string
  description = "Root user that will be created for cluster."
  default     = "root"
}

variable "aurora_security_group_id" {
  type        = string
  description = "Security group id to be attached to the created database instances. It must be a preexisting security group id, with the firewall rules that will be applied to the created cluster."
}

variable "cluster_parameter_group" {
  description = "Contains the set of engine configuration parameters that apply throughout the Aurora DB cluster. Details in https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.ParameterGroups.html#AuroraPostgreSQL.Reference.ParameterGroups-viewing-parameters"
  type = list(object({
    name         = string
    value        = any
    apply_method = string
  }))
  default = []

  validation {
    condition = alltrue([
      for obj in var.cluster_parameter_group : contains(["immediate", "pending-reboot"], obj.apply_method)
    ])
    error_message = "The 'apply_method' field must be 'immediate' or 'pending-reboot'."
  }
}

variable "db_instance_parameter_group" {
  description = "Is the set of engine configuration values that apply to a specific DB instance of that engine type."
  type = list(object({
    name         = string
    value        = any
    apply_method = string
  }))
  default = []

  validation {
    condition = alltrue([
      for obj in var.db_instance_parameter_group : contains(["immediate", "pending-reboot"], obj.apply_method)
    ])
    error_message = "The 'apply_method' field must be 'immediate' or 'pending-reboot'."
  }
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
  default     = false
}

variable "deletion_protection" {
  type        = bool
  description = "Specifies whether the DB cluster is protected from being accidentally deleted."
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Specifies whether minor engine upgrades are applied automatically to the DB cluster during the maintenance window."
  default     = true
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Enable to allow major engine version upgrades when changing engine versions."
  default     = false
}

variable "monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB cluster."
  default     = 0
}

variable "create_kms_key" {
  type        = bool
  description = "Whether a KMS key will be created for the cluster."
  default     = false
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 30

  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "The 'kms_key_deletion_window_in_days' field must be between 7 and 30 days."
  }
}
