locals {
  role_name = "global"
  team      = "ops"

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

  github_ci_policies = {
    github_ci_policy_arns = [
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      aws_iam_policy.github_ci_role_iam.arn,
    ]
  }
}
