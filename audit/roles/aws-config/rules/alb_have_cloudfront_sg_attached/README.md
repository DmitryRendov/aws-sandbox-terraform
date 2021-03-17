# alb_have_cloudfront_sg_attached

A Terraform module to deploy a custom AWS Config rule to check whether Application Load Balancers have CloudFront security groups attached

## Information

* This Config rule should be deployed to every region you want to cover with Organization AWS Config service.
* Please note that global resources recording should be enabled only in one region (us-east-1) in order to avoid resource duplication.

## ORG Config rules

* Please note, that every Custom ORG Config rules should use shared IAM roles are passed to every custom Config rule. Is used two IAM roles:
  * `audit-aws-config-org-lambda-role` - the IAM role to run custom Lambda function;
  * `audit-aws-config-reporter-cross-account` - the IAM role that custom Lambda function can assume in other AWS accounts.
* When developing new Custom ORG Config rule make sure that it has "ExecutionRoleName" is set to `audit-aws-config-reporter-cross-account` and run under this role. Otherwise, your function won't work as expected.

## Accepted parameters

None

## Examples

Deploy a custom Config Rule with a overriden maximum execution frequency (Default is `TwentyFour_Hours`):
```
module "alb_have_cloudfront_sg_attached" {
  source = "./rules/alb_have_cloudfront_sg_attached_check"

  maximum_execution_frequency = "One_Hour"
  exclude_accounts            = []
  aws_account_map  = var.aws_account_map
  aws_account_ids  = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id
}
```

Deploy a custom Config Rule to our second supported region us-east-1:
```
module "alb_have_cloudfront_sg_attached_east" {
  source = "./rules/alb_have_cloudfront_sg_attached_check"

  maximum_execution_frequency = "TwentyFour_Hours"
  exclude_accounts            = []
  aws_account_map  = var.aws_account_map
  aws_account_ids  = distinct(values(var.aws_account_map))

  org_lambda_role_id               = aws_iam_role.org_lambda_role.id
  org_lambda_cross_account_role_id = module.org_lambda_cross_account_role_label.id

  providers = {
    aws = aws.east
  }
}
```


<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `alarm_actions` |Actions to take if there are errors in the lambda function |list(string) | `[]` | no |
| `alarm_enabled` |Create the Cloudwatch Alarm or not |bool | `true` | no |
| `alarm_evaluation_periods` |The number of periods over which data is compared to the specified alarm threshold | | `1` | no |
| `alarm_period` |The period in seconds over which the alarm statistic is applied | | `86400` | no |
| `alarm_threshold` |The value against which the specified statistic is compared. | | `1` | no |
| `aws_account_ids` | |list(string) | `` | yes |
| `aws_account_map` |Map of all our AWS account IDs |map(string) | `` | yes |
| `exclude_accounts` |List of AWS account identifiers to exclude from the rules |list(string) | `[]` | no |
| `input_parameters` |The parameters are passed to the AWS Config Rule Lambda Function in JSON format. | | `map[]` | no |
| `log_retention` |Maximum days of log retention for the lambda function log group | | `30` | no |
| `maximum_execution_frequency` |The maximum frequency with which AWS Config runs evaluations for a rule. | | `TwentyFour_Hours` | no |
| `org_lambda_cross_account_role_id` |The name of a shared IAM role that Audit ORG Config Lambda Function assumes in other AWS accounts. |string | `` | yes |
| `org_lambda_role_id` |The name of a shared IAM role to run ORG Config Lambda Function. |string | `` | yes |
| `treat_missing_data` |Sets how to handle missing data points | | `missing` | no |

Managed Resources
-----------------
* `aws_cloudwatch_log_group.group`
* `aws_cloudwatch_metric_alarm.error`
* `aws_config_organization_custom_rule.s3_bucket_encryption_custom`
* `aws_iam_policy.lambda_policy`
* `aws_iam_role_policy_attachment.default`
* `aws_lambda_function.default`
* `aws_lambda_permission.lambda_permission`

Data Resources
--------------
* `data.archive_file.lambda_package`
* `data.aws_iam_policy_document.lambda_policy_doc`
* `data.aws_iam_role.org_lambda_role`
* `data.aws_region.current`

Child Modules
-------------
* `lambda_label` from `../../../../../modules/base/null-label/v2`
<!-- END OF TERRAFORM-DOCS HOOK -->
