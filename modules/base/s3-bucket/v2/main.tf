provider "aws" {
  alias = "src"
}

provider "aws" {
  alias = "dst"
}

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
  acl      = length(var.acl_policy_grants) > 0 ? null : "private"
  tags = merge(
    module.s3_label.tags,
    var.versioning_enabled && var.backups_enabled ? merge({ "BackupPlan" = "Daily" },
    { "crr:dst_bucket" = local.crr_bucket_name }) : {}
  )

  lifecycle_rule {
    id                                     = "abort-incomplete-multipart-uploads"
    enabled                                = true
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7

    expiration {
      days                         = 0
      expired_object_delete_marker = false
    }
  }

  dynamic "grant" {
    for_each = var.acl_policy_grants
    iterator = grant
    content {
      id          = lookup(grant.value, "id")
      type        = lookup(grant.value, "type")
      permissions = lookup(grant.value, "permissions")
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.expiration_enabled ? [1] : []
    content {
      id      = "expire-objects"
      enabled = var.expiration_enabled
      prefix  = var.expiration_prefix

      expiration {
        days = var.expiration_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.noncurrent_version_expiration_days > 0 ? [1] : []
    content {
      enabled = true
      id      = "delete-noncurrent-object-versions"
      prefix  = ""

      noncurrent_version_expiration {
        days = var.noncurrent_version_expiration_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.transition_to_ia_days > 0 || var.transition_to_onezone_ia_days > 0 || var.transition_to_glacier_days > 0 ? [1] : []
    content {
      enabled = true
      id      = "transition-to-cheaper-storage-over-time"
      prefix  = ""

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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      }
    }
  }

  versioning {
    enabled = local.versioning_enabled
  }

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

# By default, we want to block Public Access for all S3 buckets in accounts that do not need public access.
resource "aws_s3_bucket_public_access_block" "bucket" {
  provider = aws.src
  bucket   = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
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
  acl      = "private"
  tags = merge(
    module.s3_label.tags,
    { "crr:src_bucket" = local.bucket_name },
    { "crr:dst_bucket" = local.crr_bucket_name },
  )

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled                                = true
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_expiration {
      days = 14
    }
  }

  lifecycle_rule {
    prefix  = ""
    enabled = true

    expiration {
      expired_object_delete_marker = true
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
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
