locals {
  role_name = "global"
  team      = "ops"

  automation_username = "automation"

  security_hub_enabled = false

  config_recorder_enabled            = false
  config_recorder_delivery_frequency = "TwentyFour_Hours"


  developer_policies = {
    developer_production_policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      aws_iam_policy.developer_permissions.arn,
      data.terraform_remote_state.production_serverless.outputs.serverless_policy_arn,
    ]
  }

  ops_policies = {
    ops_bastion_policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      aws_iam_policy.ops_bastion_role_iam.arn,
    ]
  }

  automation_policies = {
    automation_bastion_policy_arns = {
      readonly    = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      permissions = aws_iam_policy.automation_permissions.arn
      secrets     = aws_iam_policy.automation_secrets.arn
    }
  }

}
