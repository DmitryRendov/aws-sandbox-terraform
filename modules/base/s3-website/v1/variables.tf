variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically something like `module.label`."
}

variable "hostname" {
  default = ""
}

variable "bucket_name" {
  default = ""
}

variable "parent_zone_id" {
  description = "ID of the hosted zone to contain the record"
  default     = ""
}

variable "parent_zone_name" {
  description = "Name of the hosted zone to contain the record"
  default     = ""
}

variable "index_document" {
  default = "index.html"
}

variable "error_document" {
  default = "404.html"
}

variable "routing_rules" {
  default = ""
}

variable "cors_allowed_headers" {
  type    = list(string)
  default = ["*"]
}

variable "cors_allowed_methods" {
  type    = list(string)
  default = ["GET"]
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = ["*"]
}

variable "cors_expose_headers" {
  type    = list(string)
  default = ["ETag"]
}

variable "cors_max_age_seconds" {
  default = "3600"
}

variable "logs_standard_transition_days" {
  description = "Number of days to persist in the standard storage tier before moving to the glacier tier"
  default     = "30"
}

variable "logs_glacier_transition_days" {
  description = "Number of days after which to move the data to the glacier storage tier"
  default     = "60"
}

variable "logs_expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "90"
}

variable "prefix" {
  default = ""
}

variable "versioning_enabled" {
  default = ""
}

variable "restricted_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "force_destroy" {
  default = false
}

variable "replication_source_principal_arns" {
  type        = list(string)
  default     = []
  description = "(Optional) List of principal ARNs to grant replication access from different AWS accounts"
}

variable "log_bucket" {
  description = "Name of S3 bucket to deliver access logs."
}

variable "block_public_acls" {
  default = "true"
}

variable "ignore_public_acls" {
  default = "true"
}

variable "block_public_policy" {
  default = "true"
}

variable "restrict_public_buckets" {
  default = "true"
}

variable "s3_logs_prefix" {
  default     = ""
  description = "S3 bucket logs prefix"
}

variable "s3_lifecycle_rules" {
  description = "List of lifecycle_rule objects for the s3_origin bucket managed by this module.  Refer to s3 module for correct structure."
  type = list(object({
    id         = string
    enabled    = bool
    prefix     = any
    tags       = map(string)
    expiration = any
    transition = list(object({
      days          = number
      storage_class = string
    }))
    noncurrent_version_expiration = list(object({
      days = number
    }))
    noncurrent_version_transition = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = []
}
