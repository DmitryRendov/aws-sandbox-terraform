data "aws_caller_identity" "current" {
}

data "aws_caller_identity" "src" {
  provider = aws.src
}

data "aws_caller_identity" "dst" {
  provider = aws.dst
}

data "aws_region" "dst" {
  provider = aws.dst
}

module "s3_label" {
  source          = "../../../../modules/base/label/v1"
  context         = var.label.context
  tags            = local.tags
  id_length_limit = 64
}

##
# S3 bucket
#
resource "aws_s3_bucket" "bucket" {
  provider = aws.src
  bucket   = local.bucket_name
  tags = merge(
    module.s3_label.tags,
    var.versioning_enabled && var.backups_enabled ? merge({ "BackupPlan" = "Daily" },
    { "crr:dst_bucket" = local.crr_bucket_name }) : {}
  )

  dynamic "replication_configuration" {
    for_each = var.versioning_enabled && var.backups_enabled ? [1] : []
    content {
      role = coalesce(var.destination_replication_iam_role_arn, module.s3_backups_service_role.iam_role_arn)
      rules {
        id       = "replication"
        priority = 1
        filter {}
        delete_marker_replication_status = var.replicate_deletes ? "Enabled" : null

        status = "Enabled"
        destination {
          bucket        = coalesce(var.destination_replication_bucket_arn, aws_s3_bucket.s3_backups[0].arn)
          storage_class = "STANDARD"

          dynamic "access_control_translation" {
            for_each = var.access_control_translation ? [1] : []
            content {
              owner = "Destination"
            }
          }
          account_id = var.access_control_translation ? data.aws_caller_identity.dst.account_id : null
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.s3_logging_target_bucket_id != "" ? [1] : []

    content {
      target_bucket = var.s3_logging_target_bucket_id
      target_prefix = "${var.s3_logging_target_bucket_prefix}/${data.aws_caller_identity.src.account_id}/${local.bucket_name}/"
    }
  }

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_enabled ? [1] : []

    content {
      object_lock_enabled = "Enabled"
      rule {
        default_retention {
          mode = var.object_lock_retention_mode
          days = var.object_lock_retention_days
        }
      }
    }
  }

}

resource "aws_s3_bucket_acl" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id
  acl      = length(var.acl_policy_grants) > 0 ? null : "private"

  dynamic "access_control_policy" {
    for_each = length(var.acl_policy_grants) > 0 ? [1] : []
    content {
      dynamic "grant" {
        for_each = var.acl_policy_grants
        iterator = grant
        content {
          grantee {
            id   = lookup(grant.value, "id")
            type = lookup(grant.value, "type")
          }
          permission = lookup(grant.value, "permissions")
        }
      }
      owner {
        id = data.aws_caller_identity.current.account_id
      }
    }
  }

  depends_on = [aws_s3_bucket_public_access_block.bucket]
}

# By default, we want to block Public Access for all S3 buckets in accounts that do not need public access.
resource "aws_s3_bucket_public_access_block" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = local.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  dynamic "rule" {
    for_each = var.expiration_enabled ? [1] : []
    content {
      id     = "expire-objects"
      status = var.expiration_enabled ? "Enabled" : "Disabled"

      filter {
        prefix = var.expiration_prefix
      }

      expiration {
        days = var.expiration_days
      }
    }
  }

  dynamic "rule" {
    for_each = var.noncurrent_version_expiration_days > 0 ? [1] : []
    content {
      status = "Enabled"
      id     = "delete-noncurrent-object-versions"

      filter {}

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
    }
  }

  dynamic "rule" {
    for_each = var.transition_to_ia_days > 0 || var.transition_to_onezone_ia_days > 0 || var.transition_to_glacier_days > 0 ? [1] : []
    content {
      status = "Enabled"
      id     = "transition-to-cheaper-storage-over-time"

      filter {}

      # Storage Class Options for AWS S3
      # The `storage_class` parameter in AWS S3 bucket lifecycle rules supports the following values:
      # - `STANDARD` - Default storage class for frequently accessed data
      # - `REDUCED_REDUNDANCY` - Lower redundancy, lower cost (deprecated)
      # - `STANDARD_IA` - Infrequent Access, lower cost for infrequently accessed objects
      # - `ONEZONE_IA` - One Zone Infrequent Access, single AZ storage
      # - `INTELLIGENT_TIERING` - Automatic cost optimization by moving objects between access tiers
      # - `GLACIER` - Long-term archival storage with retrieval times in hours
      # - `GLACIER_IR` - Glacier Instant Retrieval, faster access than standard Glacier
      # - `DEEP_ARCHIVE` - Lowest cost archival storage with retrieval times up to 12 hours

      dynamic "transition" {
        for_each = var.transition_to_ia_days > 0 ? [1] : []
        content {
          days          = var.transition_to_ia_days
          storage_class = "STANDARD_IA"
        }
      }
      dynamic "transition" {
        for_each = var.transition_to_onezone_ia_days > 0 ? [1] : []
        content {
          days          = var.transition_to_onezone_ia_days
          storage_class = "ONEZONE_IA"
        }
      }
      dynamic "transition" {
        for_each = var.transition_to_glacier_days > 0 ? [1] : []
        content {
          days          = var.transition_to_glacier_days
          storage_class = "GLACIER"
        }
      }
    }
  }
}


##
# S3 backups via Cross Region Replication (CRR)
#

module "s3_crr_label" {
  source     = "../../../../modules/base/label/v1"
  context    = var.label.context
  attributes = [substr(sha512(local.bucket_name), 0, 12), "crr"]
}

module "s3_backups_service_role" {
  source   = "../../../../modules/base/iam-service-role/v1"
  enabled  = var.versioning_enabled && var.backups_enabled
  services = ["s3.amazonaws.com"]
  label    = module.s3_crr_label
}

data "aws_iam_policy_document" "s3_backups_policy_doc" {
  count = var.versioning_enabled && var.backups_enabled ? 1 : 0
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold",
      "s3:GetObjectTagging",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetObjectVersionTagging",
    ]

    resources = [
      "${aws_s3_bucket.s3_backups[0].arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_backups_policy" {
  provider = aws.src
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  policy   = join("", data.aws_iam_policy_document.s3_backups_policy_doc.*.json)
  name     = "${module.s3_label.id}-${substr(sha512(local.bucket_name), 0, 12)}-policy"
  tags     = var.label.tags
}

resource "aws_iam_role_policy_attachment" "s3_crr_backups" {
  provider   = aws.src
  count      = var.versioning_enabled && var.backups_enabled ? 1 : 0
  role       = module.s3_backups_service_role.name
  policy_arn = aws_iam_policy.s3_backups_policy[0].arn
}

# Destination S3 bucket for mirroring
resource "aws_s3_bucket" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = local.crr_bucket_name
  tags = merge(
    module.s3_label.tags,
    { "crr:src_bucket" = local.bucket_name },
    { "crr:dst_bucket" = local.crr_bucket_name },
  )
}

resource "aws_s3_bucket_acl" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = aws_s3_bucket.s3_backups[0].id
  acl      = "private"

  depends_on = [aws_s3_bucket_public_access_block.s3_backups]
}

resource "aws_s3_bucket_versioning" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = aws_s3_bucket.s3_backups[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = aws_s3_bucket.s3_backups[0].id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }
  }

  rule {
    id     = "expire-delete-markers"
    status = "Enabled"

    filter {}

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = aws_s3_bucket.s3_backups[0].id

  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backups" {
  provider = aws.dst
  count    = var.versioning_enabled && var.backups_enabled ? 1 : 0
  bucket   = aws_s3_bucket.s3_backups[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_backups" {
  count    = var.versioning_enabled && var.backups_enabled && var.s3_backup_policy_enabled ? 1 : 0
  provider = aws.dst
  bucket   = aws_s3_bucket.s3_backups[0].id
  policy   = data.aws_iam_policy_document.s3_backups[0].json
}

data "aws_iam_policy_document" "s3_backups" {
  count = var.versioning_enabled && var.backups_enabled && var.s3_backup_policy_enabled ? 1 : 0
  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      aws_s3_bucket.s3_backups[0].arn,
      "${aws_s3_bucket.s3_backups[0].arn}/*",
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type        = "*"
    }
  }
}
