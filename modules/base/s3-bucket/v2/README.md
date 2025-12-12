# S3 bucket Terraform module

This Terraform module creates S3 buckets using providers 'aws.src' and 'aws.dst' for Cross Region Replication (CRR) backups.
This type of resources are supported:
* [TF S3 bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)

## Important notes:

* Please specify providers section every time (CRR functionality requirement);
* Please enable versioning if you want to enable CRR backups to us-west-2 region;
* S3 backup bucket will process SSL requests only;

## Terraform versions

Terraform >= 1.13.0 is supported.

## Usage

### Bucket setup for the S3 logging
```hcl
module "s3_logging" {
  source      = "../../../modules/base/s3-bucket/v1"
  label       = module.label

  transition_to_glacier_days = 90
  expiration_enabled         = true
  expiration_days            = 5
  object_lock_enabled        = false

  s3_logging_target_bucket_id = module.log_bucket.id

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}
```



### Private bucket with versioning enabled
```hcl
module "s3_bucket" {
  source             = "../../../modules/base/s3-bucket/v1"
  label              = module.label
  versioning_enabled = true

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}
```

### Private bucket with CRR backups and versioning enabled

```hcl
module "s3_bucket_crr" {
  source             = "../../../modules/base/s3-bucket/v1"
  label              = module.label
  versioning_enabled = true
  backups_enabled    = true

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}
```
> **Note**: be aware that CRR backups require versioning enabled as well and if you decide to disable just versioning - it means:
> -- CRR backups will be disabled automatically;
> -- require you first to clean up fully the backup-ed S3 bucket (including versions);

### Private bucket with Object Lock and transition to Glacier

```hcl
module "flow_logs_bucket" {
  source = "../../../modules/base/s3-bucket/v1"

  label = module.label

  transition_to_glacier_days = 90
  expiration_enabled         = true
  expiration_days            = 365
  object_lock_enabled        = true
  object_lock_retention_days = 365

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}
```
> **Note**: be aware that Object Lock require versioning to be enabled as well.
> If object_lock_enabled is set to true then versioning will be set to enabled automatically.

## Conditional creation

Sometimes you need to have a way to create S3 resources conditionally, so the solution is to specify `count = 0`.

```hcl
# This S3 bucket will not be created
module "s3_bucket" {
  source             = "../../../modules/site/s3-bucket/v1"
  label              = module.label

  count = 0 # or count = some_condition ? 1 : 0

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
  # ... omitted
}
```

## History:

### v2:
- Support One Zone IA mode as S3 life-cycle

### v1:
- Support pre-defined IAM roles and Buckets for replication configuration
- Update replication rules to support propagating object deletions. This is enabled by default.
- S3 backup bucket policy updated to process SSL requests only
- Support our module base/label
- Add support for expiration of noncurrent object versions.
- Name lifecycle rules so Terraform plans are easier to understand.
- Convert the `lifecycle_rule` for object expiry to a `dynamic`, so we do not create a disabled rule.
- S3 logging functionality extended to use account ID in the logs path
- Support S3 logging feature for security compliance
- Support Object Lock feature for security compliance
- Support Cross Region Replication backups
- Support optional lifecycle rules to transition to cheaper S3 storage

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
