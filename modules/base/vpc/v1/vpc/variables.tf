variable "cidr" {
  description = "(Required) The CIDR block for the VPC"
  type        = string
  default     = ""
}

variable "secondary_cidr_blocks" {
  description = "(Optional) List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

variable "instance_tenancy" {
  description = "(Optional) A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "(Optional) Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "(Optional) Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "(Optional) Controls if an Internet Gateway is created"
  type        = bool
  default     = true
}

variable "label" {
  description = "(Required) Single `label` resource for setting context and tagging resources. Typically something like `module.label`."
}
