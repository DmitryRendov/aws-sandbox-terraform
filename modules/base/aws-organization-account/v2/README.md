### Set up account defaults

If you want to add a Service Control Policy to the account
* create the policy in one PR
* attach the policy in the second.

Below is how you attach the policy to the organization
in hs-terraform/bastion/global/accounts/accounts.tf

 ```hcl
  module "audit" {
   source = "../../../modules/base/aws-organization-account/v2"
   name   = "audit"
   scp_policies = [
     aws_organizations_policy.s3_deny_version_deletion.id,
     aws_organizations_policy.deny_disallowed_regions.id,
   ]
 }
 ```

### V1
- Initial support for AWS Organization

### V2
- add Service Control Policies (SCP) to the Organization

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `email` |Primary contact email address for an account | | `` | no |
| `environment` |Optional, name of environment | | `` | no |
| `name` |Name of AWS Account | | `` | yes |
| `scp_policies` |Organization Policies to apply to an account. Such as denydisallowedregions |list(string) | `[]` | no |

## Outputs
| Name | Description |
|------|-------------|
| `account` |  |
| `account_email` |  |
| `account_id` |  |
| `account_name` |  |

Managed Resources
-----------------
* `aws_organizations_account.account`
* `aws_organizations_policy_attachment.attach_policies`
<!-- END OF TERRAFORM-DOCS HOOK -->
