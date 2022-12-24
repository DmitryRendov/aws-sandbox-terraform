module "dmitry_rendov" {
  source = "../../../modules/user-roles/v1"
  name   = "dmitry_rendov"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  production_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "aliaksei_kliashchonak" {
  source = "../../../modules/user-roles/v1"
  name   = "aliaksei_kliashchonak"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = [aws_iam_policy.deactivated_user.arn]
  production_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "arseni_dudko" {
  source = "../../../modules/user-roles/v1"
  name   = "arseni_dudko"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = [aws_iam_policy.deactivated_user.arn]
  production_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}
