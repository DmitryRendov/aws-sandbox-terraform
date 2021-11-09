## IAM Service Role
This module wraps around creating an iam role with custom services.

## Example Usage
```hcl
module "consumer_iam_role" {
  source      = "../../../modules/base/iam-service-role/v1"

  services    = ["lambda.amazonaws.com"]
  label       = module.label
}
```

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
