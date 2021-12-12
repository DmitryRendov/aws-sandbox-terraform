locals {
  bucket_name      = var.bucket_name == "" ? module.default_label.s3_bucket_name : var.bucket_name
  public_access_ok = ! var.block_public_acls || ! var.ignore_public_acls || ! var.block_public_policy || ! var.restrict_public_buckets
}
