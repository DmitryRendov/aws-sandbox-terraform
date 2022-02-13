<!-- BEGIN_TF_DOCS -->
## Purpose
This module is used to create parameters in AWS Parameter Store. Secure Strings created with this module use a default value of `not_secret` and have no option set or update the value because that would cause the secret to live in our Terraform state files.
The purpose of this module to to create secrets with a standardized naming and tag convention. There are three important tags that this module creates that are used by other roles:
* label
* username
* secret

`label`: is used to give developers and services access to the secrets their teams own. As long as the tag `team` tag on the label on the secret matches the team tag on the developer role they will have full access to the secret. And as long as the `role_name` and `environment` tag on the label matches the services `role_name` and `environment` of the service, the service will have the ability to read
`username`: is used to only a specfic user access to the secret.
`secret`: used to indicate if parameters are (not) secret and can have relaxed controls and IAM Permissions

Note: We don't keep any secrets in Terraform, just provision placeholder in SSM. You need to pre-populate it on your own via AWS cli or API.

## Example Usage
> This example creates a new secret string parameter with the default value `not_secret`.
```hcl
module "secret" {
  source = "../../../modules/site/ssm-parameter/v1"
  secret_name = "mysql_password"
  type = "SecureString"
  description = "MySQL password for service"
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

<!-- END_TF_DOCS -->
