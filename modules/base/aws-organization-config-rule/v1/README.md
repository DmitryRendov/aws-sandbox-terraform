# AWS Organization Config Rule

A Terraform module to create an AWS Config rule across an organization

## Examples

Deploy a custom Config Rule:
```
data "archive_file" "vpc_main_route_table_unused" {
  type        = "zip"
  source_file = "${path.module}/files/vpc_main_route_table_unused/vpc_main_route_table_unused.py"
  output_path = "${path.module}/files/vpc_main_route_table_unused.zip"
}

module "vpc_main_route_table_unused" {
  source = "../../../modules/base/aws-organization-config-rule/v2"

  name             = "vpc_main_route_table_unused"
  archive_file     = data.archive_file.vpc_main_route_table_unused
  description      = "Lambda for Custom Config Rule to ensure the main route tables for VPCs are unused."
  lambda_handler   = "vpc_main_route_table_unused.lambda_handler"
  label            = module.label
  label_attributes = ["vpc", "main", "route", "table"]
  exclude_accounts = local.exclude_accounts
  aws_account_map  = var.aws_account_map
  aws_account_ids  = distinct(values(var.aws_account_map))
  memory_size      = 512

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id

  input_parameters = {
      "ExecutionRoleName" = ""
  }
  providers = {
    aws.east = aws.east
  }
}
```

## History

### v2
- Add memory_size and timeout variables

### v1
- Initial Version

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `alarm_actions` |Actions to take if there are errors in the lambda function |list(string) | `[]` | no |
| `alarm_enabled` |Create the Cloudwatch Alarm or not |bool | `true` | no |
| `alarm_evaluation_periods` |The number of periods over which data is compared to the specified alarm threshold | | `1` | no |
| `alarm_period` |The period in seconds over which the alarm statistic is applied | | `86400` | no |
| `alarm_threshold` |The value against which the specified statistic is compared. | | `1` | no |
| `archive_file` |A `archive_file` data resource for the lambda file. | | `` | yes |
| `aws_account_ids` | |list(string) | `` | yes |
| `aws_account_map` |Map of all our AWS account IDs |map(string) | `` | yes |
| `description` |Description for the org config rule |string | `` | yes |
| `exclude_accounts` |List of AWS account identifiers to exclude from the rules |list(string) | `[]` | no |
| `input_parameters` |The parameters are passed to the AWS Config Rule Lambda Function in JSON format. | | `map[]` | no |
| `label` |Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`. | | `` | yes |
| `label_attributes` |Additional label attributes (e.g. policy or role) |list(string) | `[]` | no |
| `lambda_environment_variables` |Map of environment variables to pass to the config check lambda |map(string) | `map[LOG_LEVEL:INFO]` | no |
| `lambda_handler` |Handler for the config check lambda |string | `` | yes |
| `log_retention` |Maximum days of log retention for the lambda function log group | | `30` | no |
| `maximum_execution_frequency` |The maximum frequency with which AWS Config runs evaluations for a rule. | | `TwentyFour_Hours` | no |
| `memory_size` |Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128 | | `128` | no |
| `name` |Name of the org config rule |string | `` | yes |
| `org_lambda_cross_account_role_id` |The name of a shared IAM role that Audit ORG Config Lambda Function assumes in other AWS accounts. |string | `` | yes |
| `org_lambda_role_id` |The name of a shared IAM role to run ORG Config Lambda Function. |string | `` | yes |
| `s3_bucket` |Amazon S3 bucket name where the .zip file containing your deployment package is stored | | `` | yes |
| `s3_key` |The Amazon S3 object (the deployment package) key name you want to upload | | `` | yes |
| `timeout` |Amount of time your Lambda Function has to run in seconds. Defaults to 600 | | `600` | no |
| `treat_missing_data` |Sets how to handle missing data points | | `missing` | no |
| `trigger_types` |List of notification types that trigger AWS Config to run an evaluation for the rule. Valid values: ConfigurationItemChangeNotification, OversizedConfigurationItemChangeNotification, and ScheduledNotification |list(string) | `[ScheduledNotification]` | no |

## Outputs
| Name | Description |
|------|-------------|
| `rule` | Organization custom rule object |
| `rule_east` | Organization custom rule object (region: us-east-1) |

Managed Resources
-----------------
* `aws_config_organization_custom_rule.default`
* `aws_config_organization_custom_rule.default_east`
* `aws_lambda_permission.lambda_permission`
* `aws_lambda_permission.lambda_permission_east`

Data Resources
--------------
* `data.aws_iam_role.org_lambda_role`
* `data.aws_region.current`
* `data.aws_region.east`

Child Modules
-------------
* `lambda` from `../../../../modules/site/lambda/v7`
* `lambda_east` from `../../../../modules/site/lambda/v7`
* `lambda_label` from `../../../../modules/site/label/v1`
* `lambda_label_east` from `../../../../modules/site/label/v1`
<!-- END OF TERRAFORM-DOCS HOOK -->
