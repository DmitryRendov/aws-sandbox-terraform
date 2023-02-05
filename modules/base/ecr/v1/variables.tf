variable "name" {
  description = "Name of service"
}

variable "namespace" {
  description = "Namespace for repository. Use Sandbox for consistency if possible."
  default     = "sandbox"
}

variable "staging_tag_prefix" {
  description = "Prefix of staging tags to remove"
  default     = "candidate"
}

variable "prod_tag_prefix" {
  description = "Prefix of production tags to remove"
  default     = "release"
}

variable "job_tag_prefix" {
  description = "Prefix of one-time job tags to remove"
  default     = "job"
}

variable "version_tag_prefix" {
  description = "Prefix of one-time job tags to remove"
  default     = "v"
}

variable "cross_accounts" {
  type        = list(string)
  default     = []
  description = "Which accounts need to pull from ECR repo"
}

variable "max_image_count" {
  type        = string
  description = "Number of Docker Image versions AWS ECR will store"
  default     = "50"
}

data "template_file" "rules" {
  template = file("${path.module}/rules.json.tpl")

  vars = {
    max_image_count    = var.max_image_count
    staging_tag_prefix = var.staging_tag_prefix
    prod_tag_prefix    = var.prod_tag_prefix
    job_tag_prefix     = var.job_tag_prefix
    version_tag_prefix = var.version_tag_prefix
  }
}

variable "label" {
  type        = any
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}
