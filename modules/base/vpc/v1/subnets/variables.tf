variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created (e.g. `vpc-aceb2723`)"
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID the public route table will point to (e.g. `igw-9c26a123`)"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "external_nat_ips" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with use_existing_eips)"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets CIDRs inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets CIDRs inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "vpc_default_route_table_id" {
  type        = string
  default     = ""
  description = "Default route table for public subnets. If not set, will be created. (e.g. `rtb-f4f0ce12`)"
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Instances launched into a public subnet should be assigned a public IP address"
}

variable "public_label" {
  description = "Label passed to the module."
  type        = any
  default     = {}
}

variable "private_label" {
  description = "Label passed to the module."
  type        = any
  default     = {}
}

variable "nat_label" {
  description = "Label passed to the module."
  type        = any
  default     = {}
}
