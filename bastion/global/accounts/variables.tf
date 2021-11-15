variable "allowed_regions" {
  description = "Allow access to any operations only within the regions listed below. Default: [\"us-west-2\",\"us-east-1\",\"eu-central-1\"]"
  type        = list(string)
  default     = ["us-west-2", "us-east-1", "eu-central-1"]
}

variable "protected_iam_roles" {
  description = "List of roles that are not allowed to modify"
  type        = list(string)
  default     = ["arn:aws:iam::*:role/super-user"]
}