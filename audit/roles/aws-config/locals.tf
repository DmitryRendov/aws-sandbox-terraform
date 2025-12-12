locals {
  team      = "ops"
  role_name = "aws-config"

  config_enabled = false

  aggregator_source_regions = ["us-west-2", "us-east-1", "eu-central-1"]
  exclude_accounts = [
    var.aws_account_map.production,
  ]

  # The maximum frequency with which AWS Config runs evaluations for a rule.
  default_execution_frequency = "TwentyFour_Hours"

  ##
  # AMI Check Config rule variables
  # Bake time for approved AMIs in days. Default by environment: (prod: 14, staging: 7, integration/other: 0)
  ami_bake_time_days = {
    prod        = 15
    staging     = 8
    integration = 1
  }
  # Comma separated list of AMI prefixes that we will scan for approved AMIs.
  ami_prefixes = "ecs_"
  # (Optional) Comma separated list of AMI Id's to whitelist from AWS Config AMI rule.
  whitelisted_amis = ""

  # Threshold values for GuardDuty findings to get archived (currently set to defaults)
  guardduty_findings_thresholds = jsonencode({
    daysHighSev   = "1"
    daysMediumSev = "7"
    daysLowSev    = "30"
  })
  guardduty_central_account = jsonencode({
    CentralMonitoringAccount = data.aws_caller_identity.current.account_id
  })
  guardduty_evaluation_frequency = "One_Hour"
}
