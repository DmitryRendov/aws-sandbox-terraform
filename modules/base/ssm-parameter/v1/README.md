<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | ../../../base/label/v1 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.default_secure_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.default_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | What is this secret used for. | `any` | n/a | yes |
| <a name="input_label"></a> [label](#input\_label) | Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`. | `any` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Secret name will be /role\_name/environment/secret\_name | `any` | n/a | yes |
| <a name="input_tier"></a> [tier](#input\_tier) | Either Standard or Advanced. Advanced is needed for secrets greater than 4k | `string` | `"Standard"` | no |
| <a name="input_type"></a> [type](#input\_type) | Either SecureString or String | `any` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | User who has access to secret | `string` | `"NONE"` | no |
| <a name="input_value"></a> [value](#input\_value) | Value of the parameter, not used for secure strings | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter"></a> [parameter](#output\_parameter) | The SSM Parameter resource managed by this role |
<!-- END_TF_DOCS -->
