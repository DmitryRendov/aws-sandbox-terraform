# aws-config-recorder

A Terraform module to configure AWS Config service in our AWS accounts and enable config items recorder.

## Note

* Please note that global resources recording is enabled only in one region(us-east-1) per an account in order to avoid resource duplication

## Examples

An example AWS Config enabled in us-east-1 region with enabled global resource recording:
```
module "aws_config_recorder_east" {
  source      = "../../../modules/base/aws-config-recorder/v2"
  environment = terraform.workspace
  label       = module.label

  delivery_frequency      = "One_Hour"
  s3_bucket               = data.terraform_remote_state.audit.outputs.aws_config_bucket_name

  # Here, you can specify what exactly region AWS Config service should be enabled in
  providers = {
    aws = aws.east
  }
}
```

## History


### v2
- Update the module to TF 0.15.5, fix providers

### v1
- Update to support new labels module
- Fix `record_global_resources` variable
- Initial release (decoupled from aws-config module)

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `config_recorder_enabled` |Config Recorder enabled or not. | | `true` | no |
| `delivery_frequency` |The frequency with which AWS Config delivers configuration snapshots. | | `One_Hour` | no |
| `label` |Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`. | | `` | yes |
| `record_global_resources` |Record global resources or not (eg. IAM, CloudFront, etc.) | | `true` | no |
| `s3_bucket_name` |The name of the S3 bucket used to store the configuration history. | | `` | yes |

Managed Resources
-----------------
* `aws_config_configuration_recorder.config_recorder`
* `aws_config_configuration_recorder_status.config_recorder`
* `aws_config_delivery_channel.config_recorder`
* `aws_iam_role.awsconfig`
* `aws_iam_role_policy_attachment.AWSConfig`

Data Resources
--------------
* `data.aws_iam_policy_document.assume_role`
* `data.aws_region.current`

Child Modules
-------------
* `config_label` from `../../../../modules/site/label/v1`
* `label` from `../../../../modules/site/label/v1`
<!-- END OF TERRAFORM-DOCS HOOK -->
