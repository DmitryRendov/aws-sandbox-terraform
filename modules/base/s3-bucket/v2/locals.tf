locals {
  bucket_name        = signum(length(var.bucket_name)) == 1 ? var.bucket_name : module.s3_label.s3_bucket_name
  public_access_ok   = false == var.block_public_acls || false == var.ignore_public_acls || false == var.block_public_policy || false == var.restrict_public_buckets
  crr_bucket_name    = signum(length(var.crr_bucket_name)) == 1 ? var.crr_bucket_name : substr("${local.bucket_name}-${data.aws_region.dst.name}", 0, min(length("${local.bucket_name}-${data.aws_region.dst.name}"), 63))
  versioning_enabled = var.object_lock_enabled ? true : var.versioning_enabled

  tags = merge(
    var.tags,
    {
      "audit:public_access_ok" = local.public_access_ok
    },
  )
}
