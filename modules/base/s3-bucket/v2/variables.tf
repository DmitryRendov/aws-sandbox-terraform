variable "versioning_enabled" {
  description = "Enable object versioning in the new bucket"
  default     = true
}

variable "bucket_name" {
  description = "Name of new s3 bucket"
  default     = ""
}

variable "expiration_enabled" {
  description = "Enable/disable expiration of S3 objects"
  default     = false
  type        = bool
}

variable "expiration_prefix" {
  description = "Prefix of objects to expire"
  default     = ""
}

variable "expiration_days" {
  description = "Number of days before expiring"
  default     = "90"
}

variable "tags" {
  description = "Additional Tags to include on resource"
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  default     = true
  description = "Block public ACLs for this bucket."
  type        = bool
}

variable "ignore_public_acls" {
  default     = true
  description = "Ignore public ACLs for this bucket."
  type        = bool
}

variable "block_public_policy" {
  default     = true
  description = "Block public bucket policies for this bucket."
  type        = bool
}

variable "restrict_public_buckets" {
  default     = true
  description = "Restrict public bucket policies for this bucket."
  type        = bool
}

variable "team" {
  default     = ""
  description = "Team responsible for infrastructure"
}

variable "destination_replication_bucket_arn" {
  default     = ""
  description = "Destination replication bucket arn that will be used to replicate the source bucket."
  type        = string
}

variable "destination_replication_iam_role_arn" {
  default     = ""
  description = "Destination replication role arn that will be used to replicate the source s3 files to the destination bucket."
}

variable "backups_enabled" {
  description = "Enable S3 Cross Region Replication. Requires versioning enabled."
  default     = false
  type        = bool
}

variable "crr_bucket_name" {
  description = "Custom bucket name for S3 Cross Region Replication."
  default     = ""
}

variable "access_control_translation" {
  description = "Specifies the overrides to use for object owners on replication. Is used destination account account_id."
  default     = false
  type        = bool
}

variable "transition_to_glacier_days" {
  description = "Days to wait until transitioning objects to Glacier storage"
  default     = 0
}

variable "transition_to_ia_days" {
  description = "Days to wait until transitioning objects to Infrequent Access storage"
  default     = 0
}

variable "transition_to_onezone_ia_days" {
  description = "Days to wait until transitioning objects to Onezone Infrequent Access storage"
  default     = 0
}

variable "object_lock_enabled" {
  description = "Enable Object Lock for this bucket. Note that Object Lock requires Versioning to be enabled as well."
  type        = bool
  default     = false
}

variable "object_lock_retention_mode" {
  description = "Set Object Lock mode. Valid values are `COMPLIANCE` and `GOVERNANCE`"
  type        = string
  default     = "COMPLIANCE"
  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.object_lock_retention_mode)
    error_message = "Variable 'object_lock_retention_mode' must be one of `COMPLIANCE` or `GOVERNANCE`."
  }
}

variable "object_lock_retention_days" {
  description = "Object retention perion in days"
  type        = number
  default     = 365
}

variable "s3_logging_target_bucket_id" {
  description = "S3 logging target bucket ID"
  type        = string
  default     = ""
}

variable "s3_logging_target_bucket_prefix" {
  description = "S3 logging prefix"
  type        = string
  default     = "s3"
}

variable "noncurrent_version_expiration_days" {
  default     = 0
  description = "Specifies the number of days before noncurrent object versions expire. Requires versioning enabled."
  type        = number
}

variable "acl_policy_grants" {
  description = "ACL policy grants list Note that acl is ignored if acl_policy_grants is non-empty, That means acl and acl_policy_grants are mutually exclusive"
  default     = []
}

variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}

variable "kms_key_arn" {
  description = "The ARN of a customer managed key used for server side encryption of an s3 bucket"
  type        = string
  default     = null
}

variable "s3_backup_policy_enabled" {
  description = "Enables S3 backup bucket policy"
  default     = true
}

variable "replicate_deletes" {
  description = "If 'true' - object deletions will be replicated to the target bucket. (Meaningless unless backups_enabled && versioning_enabled)"
  type        = bool
  default     = true
}
