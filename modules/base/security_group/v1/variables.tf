variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Security group description"
  type        = string
  default     = "Sceurity group created by Terraform."
}

variable "vpc_id" {
  description = "VPC ID where to create security group"
  type        = string
}

variable "revoke_rules_on_delete" {
  description = "Instruct Terraform to revoke all of the Security Groups attached ingress and egress rules before deleting the rule itself."
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of objects like: {\"description\": \"\", \"from_port\": x, \"to_port\": x, \"protocol\": \"\", \"cidr_block\": \"\"}"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "List of objects like: {\"description\": \"\", \"from_port\": x, \"to_port\": x, \"protocol\": \"\", \"cidr_block\": \"\"}"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "label" {
  description = "Label passed to the module."
  type        = any
}
