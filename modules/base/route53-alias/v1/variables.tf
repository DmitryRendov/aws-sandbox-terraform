variable "aliases" {
  type = list(string)
}

variable "private_zone" {
  default = true
}

variable "parent_zone_id" {
  default = ""
}

variable "parent_zone_name" {
  default = ""
}

variable "target_dns_name" {
}

variable "target_zone_id" {
}

variable "evaluate_target_health" {
  default = "false"
}
