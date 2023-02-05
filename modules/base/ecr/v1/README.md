## Purpose

This role helps us create ECR repositories in a standardized way.

## Usage

### A new ECR
```hcl
module "label" {
  source              = "../../../modules/base/label/v1"
  environment         = local.env
  name                = local.role_name
  team                = local.team
}

module "atlantis_service" {
  source         = "../../../modules/base/ecr/v1"
  name           = "atlantis-service"
  label          = module.label
}
```

## History:
### v1:
- Initial version

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
