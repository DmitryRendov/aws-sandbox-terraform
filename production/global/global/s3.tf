module "logging_bucket" {
  source = "../../../modules/base/s3-bucket/v1"
  label  = module.log_bucket_label

  expiration_enabled                 = true
  expiration_days                    = 1
  noncurrent_version_expiration_days = 1

  versioning_enabled = false
  backups_enabled    = false

  providers = {
    aws.src = aws
    aws.dst = aws.west
  }
}

# Logs bucket policy
resource "aws_s3_bucket_policy" "logging_bucket" {
  count  = local.logging_bucket_policy_count
  bucket = module.logging_bucket.id
  policy = data.aws_iam_policy_document.logging_bucket[0].json
}

data "aws_elb_service_account" "logging" {
  count = local.aws_elb_logging_enabled ? 1 : 0
}

data "aws_iam_policy_document" "logging_bucket" {
  count = local.logging_bucket_policy_count

  statement {
    sid = "CloudwatchReadAccess"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.id}.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [module.logging_bucket.arn]
  }

  statement {
    sid = "CloudwatchWriteAccess"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.id}.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.logging_bucket.arn}/*"]
  }

  dynamic "statement" {
    for_each = local.aws_elb_logging_enabled ? [1] : []

    content {
      sid       = "ReadAccessForELBLoggingAccount"
      actions   = ["s3:GetBucketAcl"]
      resources = [module.logging_bucket.arn]

      principals {
        type        = "AWS"
        identifiers = [data.aws_elb_service_account.logging[0].arn]
      }
    }
  }

  dynamic "statement" {
    for_each = local.aws_elb_logging_enabled ? [1] : []

    content {
      sid       = "WriteAccessForELBLoggingAccount"
      actions   = ["s3:PutObject"]
      resources = ["${module.logging_bucket.arn}/*"]

      principals {
        type        = "AWS"
        identifiers = [data.aws_elb_service_account.logging[0].arn]
      }
    }
  }

  dynamic "statement" {
    for_each = length(local.logging_services) != 0 ? [1] : []

    content {
      sid       = "ReadAccessForLoggingServices"
      actions   = ["s3:GetBucketAcl"]
      resources = [module.logging_bucket.arn]

      principals {
        type        = "Service"
        identifiers = local.logging_services
      }
    }
  }

  dynamic "statement" {
    for_each = length(local.logging_services) != 0 ? [1] : []

    content {
      sid       = "WriteAccessForLoggingServices"
      actions   = ["s3:PutObject"]
      resources = ["${module.logging_bucket.arn}/*"]

      principals {
        type        = "Service"
        identifiers = local.logging_services
      }

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
    }
  }

  dynamic "statement" {
    for_each = local.enforce_logging_bucket_tls ? [1] : []

    content {
      sid     = "EnforceUsingTLS"
      actions = ["s3:*"]
      effect  = "Deny"

      resources = [
        module.logging_bucket.arn,
        "${module.logging_bucket.arn}/*"
      ]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = [false]
      }
    }
  }
}
