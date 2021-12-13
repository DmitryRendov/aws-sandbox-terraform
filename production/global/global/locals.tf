locals {
  role_name = "global"
  team      = "ops"

  aws_log_delivery_service_enabled    = false
  aws_elb_logging_enabled             = false
  aws_cloudwatch_logs_service_enabled = true
  aws_cloudtrail_logging_enabled      = false
  aws_config_logging_enabled          = true
  enforce_logging_bucket_tls          = true
  aws_cloudwatch_logs_regions         = ["us-east-1", "us-west-2"]

  logging_bucket_policy_count = (
    local.aws_log_delivery_service_enabled ||
    local.aws_elb_logging_enabled ||
    local.aws_cloudwatch_logs_service_enabled ||
    local.aws_cloudtrail_logging_enabled ||
    local.aws_config_logging_enabled ||
    local.enforce_logging_bucket_tls
  ) ? 1 : 0

  logging_services = concat(
    local.aws_log_delivery_service_enabled ? ["delivery.logs.amazonaws.com"] : [],
    local.aws_cloudtrail_logging_enabled ? ["cloudtrail.amazonaws.com"] : [],
    local.aws_config_logging_enabled ? ["config.amazonaws.com"] : [],
    local.aws_cloudwatch_logs_service_enabled ? formatlist("logs.%s.amazonaws.com", local.aws_cloudwatch_logs_regions) : []
  )
}
