locals {
  team      = "developers"
  role_name = "serverless"

  # API Gateway
  api_gateway_name           = "${module.label.id}-public"
  api_version                = "v1"
  api_type                   = "EDGE"
  api_metrics_enabled        = "false"
  api_data_trace_enabled     = "false"
  api_logging_level          = "INFO"
  api_throttling_rate_limit  = 1000
  api_throttling_burst_limit = 100
  api_logs_retention_in_days = 30
  api_xray_tracing_enabled   = "false"

  # Hostname for serverless web-site (xn--b1add1bfm.xn--90ais)
  hostname = data.terraform_remote_state.route53.outputs.zone_name
}
