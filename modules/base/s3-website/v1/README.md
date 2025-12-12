# Terraform module for creating S3 backed Websites

## Further Reading
http://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html

## Terraform versions
Terraform >= 1.13.0 is supported.

## Usage

### Website creation with CNAME

```hcl
module "website_with_cname" {
  source  = "../../../modules/base/s3-website/v1"
  label   = module.website_label

  hostname               = "${module.role_name}.${terraform.workspace}.${var.vpc_dns_zone_name}"
  parent_zone_id         = data.terraform_remote_state.route53.outputs.zone_id
  lifecycle_rule_enabled = false
  versioning_enabled     = false
  error_document         = "index.html"

  log_bucket     = data.terraform_remote_state.global.outputs.logging_bucket.id
  s3_logs_prefix = "s3/${local.aws_account_id}"

  restricted_ips = module.sandbox_ips.subnets

  s3_lifecycle_rules = [
    {
      id         = "ExpireOldVersions"
      transition = []
      tags       = {}
      enabled    = true
      expiration = [{
        days                         = 1
        expired_object_delete_marker = true
      }]
      prefix                        = ""
      noncurrent_version_transition = []
      noncurrent_version_expiration = [{
        days                         = 1
        expired_object_delete_marker = true
      }]
    }
  ]
}
```

## History:

### v1
- Base S3 website module

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
