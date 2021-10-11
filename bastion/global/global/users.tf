module "dmitry_rendov" {
  source = "../../../modules/user-roles/v1"
  name   = "dmitry_rendov"

  audit_policy_arns   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  bastion_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  providers = {
    aws.audit = aws.audit
  }
}

module "aliaksei_kliashchonak" {
  source = "../../../modules/user-roles/v1"
  name   = "aliaksei_kliashchonak"

  audit_policy_arns   = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  bastion_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit = aws.audit
  }
}

module "mikhail_parkun" {
  source = "../../../modules/user-roles/v1"
  name   = "mikhail_parkun"

  audit_policy_arns   = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit = aws.audit
  }
}
