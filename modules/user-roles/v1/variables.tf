variable "name" {
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "teams" {
  type        = set(string)
  default     = []
  description = "List of teams to tag the user with"
}

variable "bastion_policy_arns" {
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  description = "List of policy arns to attach to the user for the Bastion Account. Default: ReadOnlyAccess"
}

variable "audit_policy_arns" {
  type        = set(string)
  default     = []
  description = "List of policy arns to attach to the user for the Audit Account."
}

variable "production_policy_arns" {
  type        = set(string)
  default     = []
  description = "List of policy arns to attach to the user for the Production Account."
}

variable "support_policy_arns" {
  type        = set(string)
  default     = ["arn:aws:iam::aws:policy/AWSSupportAccess"]
  description = "List of policy arns to attach to the user for AWS Support access.  Default: AWSSupportAccess"
}
