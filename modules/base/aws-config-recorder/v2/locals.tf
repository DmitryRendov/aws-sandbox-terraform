locals {
  # Record global resources only in one region
  record_global_resources = data.aws_region.current.name == "us-east-1" ? true : false
}
