variable "zones" {
  description = <<EOF
    (Required) List of maps of Route53 zones parameters defined below

    (Required) domain_name - Specifies the name of the hosted zone.If the value is not set map key will be used
    (Optional) comment - Specifies comment for the hosted zone. Defaults to 'Managed by Terraform'.
    (Optional) force_destroy - Whether to destroy all records in the zone when destroying the zone.
    (Optional) vpc - Configuration block(s) specifying VPC(s) to associate with a private hosted zone.
    (Optional) unique_tags - Unique map of tags to assign to the zone
  EOF
  type        = list(any)
}

variable "shared_tags" {
  description = "(Optional) Tags added to all zones."
  type        = any
  default     = {}
}
