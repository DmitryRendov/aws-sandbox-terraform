
variable "description" {
  description = "What is this secret used for."
}

variable "secret_name" {
  description = "Secret name will be /role_name/environment/secret_name"
}

variable "username" {
  description = "User who has access to secret"
  default     = "NONE"
}

variable "value" {
  description = "Value of the parameter, not used for secure strings"
  default     = ""
}

variable "type" {
  description = "Either SecureString or String"
}

variable "tier" {
  description = "Either Standard or Advanced. Advanced is needed for secrets greater than 4k"
  default     = "Standard"
}

variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}
