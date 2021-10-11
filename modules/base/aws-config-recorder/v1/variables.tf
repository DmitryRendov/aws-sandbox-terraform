variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}

variable "delivery_frequency" {
  default     = "One_Hour"
  description = "The frequency with which AWS Config delivers configuration snapshots."
}

variable "config_recorder_enabled" {
  default     = true
  description = "Config Recorder enabled or not."
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket used to store the configuration history."
}

variable "record_global_resources" {
  default     = true
  description = "Record global resources or not (eg. IAM, CloudFront, etc.)"
}
