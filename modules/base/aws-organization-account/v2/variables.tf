variable "email" {
  description = "Primary contact email address for an account"
  default     = ""
}

variable "environment" {
  description = "Optional, name of environment"
  default     = ""
}

variable "name" {
  description = "Name of AWS Account"
}

variable "scp_policies" {
  description = "Organization Policies to apply to an account. Such as denydisallowedregions"
  type        = list(string)
  default     = []
}
