<!-- BEGIN_TF_DOCS -->
## Purpose
This module is used for providing read and write access to the AWS SSM Parameter Store.


## Example Usage
> This example creates a new String parameter called /prod/app/database/master_password with the value of password1.
```hcl
module "store_write" {
  source          = "../../../modules/base/ssm-parameter-store/v1"
  parameter_write = [
    {
      name        = "/prod/app/database/master_password"
      value       = "password1"
      type        = "String"
      overwrite   = "true"
      description = "Production database master password"
    }
  ]

  label = module.label
}
```
> This example reads a value from the parameter store with the name /prod/app/database/master_password
```hcl
module "store_read" {
  source          = "../../../modules/base/ssm-parameter-store/v1"
  parameter_read  = ["/prod/app/database/master_password"]

  label = module.label
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.73.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.ignore_value_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_arn"></a> [kms\_arn](#input\_kms\_arn) | The ARN of a KMS key used to encrypt and decrypt SecretString values | `string` | `""` | no |
| <a name="input_label"></a> [label](#input\_label) | Label passed to the module. | `any` | `{}` | no |
| <a name="input_parameter_read"></a> [parameter\_read](#input\_parameter\_read) | List of parameters to read from SSM. These must already exist otherwise an error is returned. Can be used with `parameter_write` as long as the parameters are different. | `list(string)` | `[]` | no |
| <a name="input_parameter_write"></a> [parameter\_write](#input\_parameter\_write) | List of maps with the parameter values to write to SSM Parameter Store | `list(map(string))` | `[]` | no |
| <a name="input_parameter_write_defaults"></a> [parameter\_write\_defaults](#input\_parameter\_write\_defaults) | Parameter write default settings | `map(any)` | <pre>{<br>  "allowed_pattern": null,<br>  "data_type": "text",<br>  "description": null,<br>  "overwrite": "false",<br>  "tier": "Standard",<br>  "type": "SecureString"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn_map"></a> [arn\_map](#output\_arn\_map) | A map of the names and ARNs created |
| <a name="output_map"></a> [map](#output\_map) | A map of the names and values created |
| <a name="output_names"></a> [names](#output\_names) | A list of all of the parameter names |
| <a name="output_values"></a> [values](#output\_values) | A list of all of the parameter values |
<!-- END_TF_DOCS -->