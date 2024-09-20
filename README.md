# terraform-aws-rds-cluster
<!-- BEGIN MadeLabs Header -->
![MadeLabs is for hire!](https://d2xqy67kmqxrk1.cloudfront.net/horizontal_logo_white.png)
MadeLabs is proud to support the open source community with these blueprints for provisioning infrastructure to help software builders get started quickly and with confidence. 

We're also for hire: [https://www.madelabs.io](https://www.madelabs.io)

<!-- END MadeLabs Header -->
---
A Terraform module for managing a simple Aurora Postgres cluster. 
It gets a list of inputs, and creates an Aurora Postgres Cluster, with a configurable number of instances. In addition, it creates a secret on AWS Secrets Manager, to store credentials to access the recently created cluster. This output secret has the root user, password, endpoint and reader_endpoint, that represents the read-only endpoint for the Aurora cluster, automatically load-balanced across replicas.
 You can see more information on [aws_rds_cluster documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#reader_endpoint).

There is a naming convention for the created resources, and the caller is allowed to provide some prefixes and suffixes, that are used to build the names.
The caller can also choose between providing a password through an AWS Secrets Manager Secret, or let the module generate a password for it.

It supports Enhanced Monitoring, performance insights and auto-scale.

![PlantUML model](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/madelabs/terraform-aws-rds-cluster/main/docs/diagram.puml)

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.12.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.aurora_scaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.aurora_scaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_db_parameter_group.aurora_db_parameter_group_p](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cluster_storage_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.cluster_storage_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_rds_cluster.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_secretsmanager_secret.aurora_access_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.aurora_access_data_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.aurora_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cluster_storage_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.context](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_rds_engine_version.family](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_engine_version) | data source |
| [aws_secretsmanager_secret_version.aurora_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions. | `bool` | `false` | no |
| <a name="input_apply_changes_immediately"></a> [apply\_changes\_immediately](#input\_apply\_changes\_immediately) | Changes to an RDS Cluster can occur when you manually change a parameter, such as port, and are reflected in the next maintenance window. You can use the apply\_changes\_immediately flag to instruct the service to apply the change immediately. | `bool` | `true` | no |
| <a name="input_aurora_security_group_id"></a> [aurora\_security\_group\_id](#input\_aurora\_security\_group\_id) | Security group id to be attached to the created database instances. It must be a preexisting security group id, with the firewall rules that will be applied to the created cluster. | `string` | n/a | yes |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Specifies whether minor engine upgrades are applied automatically to the DB cluster during the maintenance window. | `bool` | `true` | no |
| <a name="input_auto_scale_max_capacity"></a> [auto\_scale\_max\_capacity](#input\_auto\_scale\_max\_capacity) | The maximum capacity, i.e. number of instances that will provided by the auto-scale, when enable\_auto\_scale is true. | `number` | `5` | no |
| <a name="input_auto_scale_metric"></a> [auto\_scale\_metric](#input\_auto\_scale\_metric) | Defines the metric to be used when enable\_auto\_scale is true. The possible values are RDSReaderAverageCPUUtilization and RDSReaderAverageDatabaseConnections. | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| <a name="input_auto_scale_min_capacity"></a> [auto\_scale\_min\_capacity](#input\_auto\_scale\_min\_capacity) | The minimum capacity, i.e. number of instances that will provided by the auto-scale, when enable\_auto\_scale is true. | `number` | `1` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | How many days will backup be kept. | `number` | `7` | no |
| <a name="input_cluster_parameter_group"></a> [cluster\_parameter\_group](#input\_cluster\_parameter\_group) | Contains the set of engine configuration parameters that apply throughout the Aurora DB cluster. Details in https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.ParameterGroups.html#AuroraPostgreSQL.Reference.ParameterGroups-viewing-parameters | <pre>list(object({<br>    name         = string<br>    value        = any<br>    apply_method = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_suffix_name"></a> [cluster\_suffix\_name](#input\_cluster\_suffix\_name) | This will be part of the cluster name and cluster instances, along with env variable value. If env='foo' and cluster\_identifier is 'bar', cluster name will be 'foo-bar'. | `string` | `"aurorapg"` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of tags that will be assigned to the database cluster. | `map(string)` | `{}` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether a KMS key will be created for the cluster. | `bool` | `false` | no |
| <a name="input_database_instance_count"></a> [database\_instance\_count](#input\_database\_instance\_count) | Number of database instances to be created in the cluster. | `number` | `1` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | If provided, a database with this name will automatically be created on cluster creation. | `string` | `null` | no |
| <a name="input_db_instance_parameter_group"></a> [db\_instance\_parameter\_group](#input\_db\_instance\_parameter\_group) | Is the set of engine configuration values that apply to a specific DB instance of that engine type. | <pre>list(object({<br>    name         = string<br>    value        = any<br>    apply_method = string<br>  }))</pre> | `[]` | no |
| <a name="input_db_master_user"></a> [db\_master\_user](#input\_db\_master\_user) | User that will be created as a master user on the created cluster. | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Port where the database will be available for connections. | `string` | `"5432"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Specifies whether the DB cluster is protected from being accidentally deleted. | `bool` | `false` | no |
| <a name="input_enable_auto_scale"></a> [enable\_auto\_scale](#input\_enable\_auto\_scale) | Whether enable or not the auto-scale feature. | `bool` | `false` | no |
| <a name="input_enable_postgresql_log"></a> [enable\_postgresql\_log](#input\_enable\_postgresql\_log) | Whether postgresql logs will be enable for the created cluster. | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Name of the environment where this infrastructure is going to be deployed, such as 'dev', 'prod' or whatever name you use. This will be a name prefix for the created resources. | `string` | n/a | yes |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made. | `string` | n/a | yes |
| <a name="input_generate_password"></a> [generate\_password](#input\_generate\_password) | Whether the password should or not be generated by the module. When the password is not generated by the module, you must provide a secret\_id, where the password will be read from. | `bool` | n/a | yes |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Whether IAM authentication will be enabled for the created cluster. | `bool` | `false` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Database Instance Class. | `string` | n/a | yes |
| <a name="input_instance_specific_tags"></a> [instance\_specific\_tags](#input\_instance\_specific\_tags) | Instance specific tags to be added to individual instances. This works in conjunction with database\_instance\_count variable. Provided instance number cannot exceed instance count. You can add a sulfix to the name of the instance by using a tag with key instance\_name. In this case, the tag value is going to be added to the instance name. | <pre>list(object({<br>    instance_number = number<br>    tag_key         = string<br>    tag_value       = string<br>  }))</pre> | `[]` | no |
| <a name="input_kms_key_deletion_window_in_days"></a> [kms\_key\_deletion\_window\_in\_days](#input\_kms\_key\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB cluster instances. | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | The IAM role arn to be used to monitor the database instances. | `string` | `""` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_performance_insights_retention_period_in_days"></a> [performance\_insights\_retention\_period\_in\_days](#input\_performance\_insights\_retention\_period\_in\_days) | Number of days to keep performance insights data. | `number` | `7` | no |
| <a name="input_postgres_version"></a> [postgres\_version](#input\_postgres\_version) | Postgres version to run. | `string` | `"13.8"` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | Daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC. | `string` | `"07:00-09:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | Weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30. | `string` | `"wed:04:00-wed:04:30"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Whether the database will be publicly accessible. If true, the VPC needs to have an Internet Gateway attached to it. | `bool` | `false` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | The number of seconds to wait, after an scale in operation, before reducing even more the capacity, i.e., the number of available instances | `number` | `300` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | The number of seconds to wait, after an scale out operation, before increasing even more the capacity, i.e., the number of available instances | `number` | `300` | no |
| <a name="input_secret_deletion_window_in_days"></a> [secret\_deletion\_window\_in\_days](#input\_secret\_deletion\_window\_in\_days) | How many days the secret will be kept after the infrastructure is destroyed. | `number` | `7` | no |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | The aws resource id where the password is stored. This is also the arn of the secret. This module reads the password and use its value as the master user password. | `string` | `""` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final\_snapshot\_identifier. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. | `bool` | `false` | no |
| <a name="input_subnet_group_name"></a> [subnet\_group\_name](#input\_subnet\_group\_name) | Name of subnet group, where the database will be connected. It must be a preexisting subnet group name on the target account. | `string` | n/a | yes |
| <a name="input_target_value_for_metric"></a> [target\_value\_for\_metric](#input\_target\_value\_for\_metric) | The target value for auto\_scale\_metric. If auto\_scale\_metric is RDSReaderAverageCPUUtilization, this number is the target percentage of CPU utilization. Let's say target\_value\_for\_metric is 70 and auto\_scale\_metric is RDSReaderAverageCPUUtilization. If there is a situation where the average of cpu utilization is higher than 70%, RDS is going to scale out (increase the number of instances, up to auto\_scale\_max\_capacity) in order to make the cpu utilization goes down. When auto\_scale\_metric RDSReaderAverageDatabaseConnections is RDSReaderAverageDatabaseConnections, this value represents tha target number of connections. If the average number of connections is higher, RDS is going to scale out. | `number` | `70` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_port"></a> [database\_port](#output\_database\_port) | n/a |
| <a name="output_rds_cluster_arn"></a> [rds\_cluster\_arn](#output\_rds\_cluster\_arn) | n/a |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | n/a |
| <a name="output_rds_cluster_resource_id"></a> [rds\_cluster\_resource\_id](#output\_rds\_cluster\_resource\_id) | n/a |
<!-- END_TF_DOCS -->
