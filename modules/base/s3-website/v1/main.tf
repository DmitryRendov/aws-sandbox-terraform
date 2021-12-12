resource "aws_s3_bucket" "default" {
  bucket        = local.bucket_name
  acl           = "public-read"
  tags          = module.default_label.tags
  force_destroy = var.force_destroy

  logging {
    target_bucket = var.log_bucket
    target_prefix = var.s3_logs_prefix == "" ? "s3/${module.default_label.name}/" : "${var.s3_logs_prefix}/${local.bucket_name}/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  website {
    index_document = var.index_document
    error_document = var.error_document
    routing_rules  = var.routing_rules
  }

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.s3_lifecycle_rules
    content {
      enabled = lifecycle_rule.value.enabled
      id      = lookup(lifecycle_rule.value, "id", null)
      prefix  = lookup(lifecycle_rule.value, "prefix", null)
      tags    = lookup(lifecycle_rule.value, "tags", null)

      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", {})
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", 0)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", false)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", {})
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", {})
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  lifecycle_rule {
    id                                     = "cleanup-incomplete-multipart-uploads"
    enabled                                = true
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7
    expiration {
      days                         = 0
      expired_object_delete_marker = false
    }
  }
}

# AWS only supports a single bucket policy on a bucket. You can combine multiple Statements into a single policy, but not attach multiple policies.
# https://github.com/hashicorp/terraform/issues/10543
resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.default.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"

      values = var.restricted_ips
    }
  }

  # Support replication ARNs
  dynamic "statement" {
    for_each = flatten(data.aws_iam_policy_document.replication.*.statement)
    content {
      actions       = lookup(statement.value, "actions", null)
      effect        = lookup(statement.value, "effect", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      not_resources = lookup(statement.value, "not_resources", null)
      resources     = lookup(statement.value, "resources", null)
      sid           = lookup(statement.value, "sid", null)

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          identifiers = not_principals.value.identifiers
          type        = not_principals.value.type
        }
      }

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          identifiers = principals.value.identifiers
          type        = principals.value.type
        }
      }
    }
  }

  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      aws_s3_bucket.default.arn,
      "${aws_s3_bucket.default.arn}/*",
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

data "aws_iam_policy_document" "replication" {
  count = signum(length(var.replication_source_principal_arns))

  statement {
    principals {
      type        = "AWS"
      identifiers = var.replication_source_principal_arns
    }

    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]

    resources = [
      aws_s3_bucket.default.arn,
      "${aws_s3_bucket.default.arn}/*",
    ]
  }
}

# By default, we want to block Public Access for all S3 buckets in accounts that do not need public access.
resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
}

module "dns" {
  source = "../../route53-alias/v1"
  aliases = compact(
    [
      signum(length(var.parent_zone_id)) == 1 || signum(length(var.parent_zone_name)) == 1 ? var.hostname : "",
    ],
  )
  parent_zone_id   = var.parent_zone_id
  parent_zone_name = var.parent_zone_name
  target_dns_name  = aws_s3_bucket.default.website_domain
  target_zone_id   = aws_s3_bucket.default.hosted_zone_id
}
