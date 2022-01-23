variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix"
  type        = bool
  default     = false
}

variable "name" {
  description = "(Required) The resource name and Name tag of the load balancer."
  type        = string
  default     = null
}

variable "internal" {
  description = "(Optional) Boolean determining if the load balancer is internal or externally facing."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
  type        = string
  default     = "ipv4"
}

variable "security_group_ids" {
  description = "(Required) The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "(Required) A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
  default     = null
}

variable "http2_enabled" {
  description = "(Optional) Indicates whether HTTP/2 is enabled in application load balancers."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "(Optional) The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "drop_invalid_header_fields" {
  description = "(Optional) Indicates whether invalid header fields are dropped in application load balancers. Defaults to false."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "access_logs" {
  description = <<EOF
    (Optional) An Access Logs block parameters defined below

    (Required) bucket - The S3 bucket name to store the logs in.
    (Optional) prefix - The S3 bucket prefix. Logs are stored in the root if not configured.
  EOF
  type        = map(string)
  default     = null
}

variable "vpc_id" {
  description = "(Optional) VPC id where the load balancer and other resources will be deployed."
  type        = string
  default     = null
}

variable "target_groups" {
  description = <<EOF
    (Optional) A list of maps containing key/value pairs that define the target groups to be created.
    Order of these maps is important and the index of these are to be referenced in listener definitions.
    Required key/values: name, backend_protocol, backend_port
  EOF
  type        = any
  default     = []
}

variable "listeners" {
  description = <<EOF
    (Optional) A list of maps describing the listeners or TCP ports for this ALB.

    Required key/values: port, protocol.
  EOF
  type        = any
  default     = []
}

variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "listener_rules" {
  description = <<EOF
    (Optional) A list of maps describing the Listener Rules for this ALB.

    Required key/values: actions, conditions.
  EOF
  type        = any
  default     = []
}

variable "label" {
  description = "(Required) Label passed to the module."
  type        = any
  default     = {}
}

variable "target_group_additional_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) The additional tags to apply to the target group"
}