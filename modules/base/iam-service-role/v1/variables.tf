variable "services" {
  description = "Specify AWS service you want to use"
  type        = list(string)
}

variable "enabled" {
  description = "Set to false and no resources will be created"
  default     = true
}

variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}
