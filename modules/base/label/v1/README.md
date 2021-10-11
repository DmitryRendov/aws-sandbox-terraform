## Purpose
This module is used to enforce standard naming and tagging conventions on our AWS resources.  The current naming convention is ```<environment>-<role name>(-<attributes>)```.  Attributes can be added to differentiate different resources of the same type, for example if there are two DynamoDB tables in the same role an attribute of `user` could be added to one and `records` to the other.

It is recommended to use one `label` module for every unique resource of a given resource type. For example, if you have 10 instances, there should be 10 different labels. However, if you have multiple different kinds of resources (e.g. instances, security groups, file systems, and elastic ips), then they can all share the same label assuming they are logically related.


### Tags
These tags are created by default:

- Name: name of the resource
- role: the role it was created in (i.e. sso, aws-config, etc)
- environment: production, staging, integration, etc
- repo: the repo and filepath where the resource Terraform lives
- team: the team responsible for maintaining this resource


### Example Usage
> Multiple different kind of resources
```hcl
module "label" {
  source              = "../../../modules/site/label/v1"
  name                = local.role_name
  environment         = local.env
}
```
> Multiple different resources of the SAME kind
```hcl
module "audio_label" {
  source              = "../../../modules/site/label/v1"
  name                = local.role_name
  environment         = local.env
  attributes          = ["audio"]
}

resource "aws_foo" "audio_foo" {
  tags = module.audio_label.tags
  name = module.audio_label.id
  ...
}

module "video_label" {
  source              = "../../../modules/site/label/v1"
  name                = local.role_name
  environment         = local.env
  attributes          = ["audio"]
}

resource "aws_foo" "audio_foo" {
  tags = module.audio_label.tags
  name = module.audio_label.id
  ...
}
```

> Combining labels to override values
* TODO: Example here

## Validating input

This module uses a sub-module `required_labels` to validate the input.
To add a new required field, or validation for existing fields, simply add the validation in the required_labels sub-module.

## Adding new required values/tags/fields

To add a new required value, add it to `local.input`, `local.id_context`, `local.output_context`.
Additionally, add validations to the `require_labels` module as described above.

## History

### v1
- Adapted from:
* Our previous `null-label` module in this repository (which is adapted from Cloudposse upstream)
* https://github.com/cloudposse/terraform-terraform-label
* https://github.com/cloudposse/terraform-null-label

Changes:
* Upstream uses `namespace` and `stage`, we choose `role` and `environment` respectively. Drop a bunch of features we don't need from the upstream.
* drop `convert_case` var from `null-label` - It is never used
* Output truncated ids by default, flag `id_brief` as deprecated, add `id_full` for non-truncated ids (copy from upstream)

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs

## Outputs

<!-- END OF TERRAFORM-DOCS HOOK -->
