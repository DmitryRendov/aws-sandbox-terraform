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

  audit_policy_arns   = ["arn:aws:iam::aws:policy/AWSReadOnlyAccess"]
  bastion_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  providers = {
    aws.audit = aws.audit
  }
}
