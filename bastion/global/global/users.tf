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

  audit_policy_arns      = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  production_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "mikhail_parkun" {
  source = "../../../modules/user-roles/v1"
  name   = "mikhail_parkun"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  production_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "ilya_melnik" {
  source = "../../../modules/user-roles/v1"
  name   = "ilya_melnik"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  production_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "arseni_dudko" {
  source = "../../../modules/user-roles/v1"
  name   = "arseni_dudko"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  production_policy_arns = local.developer_policies["developer_prod_policy_arns"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}

module "valerii_baev" {
  source = "../../../modules/user-roles/v1"
  name   = "valerii_baev"

  audit_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  bastion_policy_arns    = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  production_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  providers = {
    aws.audit      = aws.audit
    aws.production = aws.production
  }
}
