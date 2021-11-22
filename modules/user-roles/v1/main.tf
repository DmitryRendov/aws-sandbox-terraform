locals {

  # Truncates username to 16 characters for RDS requirements if username
  # is longer than 16 characters
  rds_username = substr(var.name, 0, min(16, length(var.name)))

  team_tags = {
    for team in var.teams :
    "team:${team}" => team
  }

  tags = merge(var.tags, local.team_tags)
}

resource "aws_iam_user" "user" {
  name          = var.name
  force_destroy = true
  tags          = local.tags
}

data "aws_iam_group" "sandbox" {
  group_name = "sandbox"
}

resource "aws_iam_user_group_membership" "sandbox" {
  user   = aws_iam_user.user.name
  groups = [data.aws_iam_group.sandbox.group_name]
}

resource "aws_iam_policy" "assumerole" {
  name        = "${var.name}-assumerole"
  description = "Allow a user to assume their role in every account"
  policy      = data.aws_iam_policy_document.assumerole_all.json
}

resource "aws_iam_user_policy_attachment" "assumerole" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.assumerole.arn
}

resource "aws_iam_user_policy_attachment" "bastion_user_policy" {
  for_each   = var.bastion_policy_arns
  user       = aws_iam_user.user.name
  policy_arn = each.value
}

resource "aws_iam_user_policy_attachment" "support_user_policy" {
  for_each   = var.support_policy_arns
  user       = aws_iam_user.user.name
  policy_arn = each.value
}

##
# Audit account
#
resource "aws_iam_role" "audit_user_role" {
  count              = signum(length(var.audit_policy_arns))
  provider           = aws.audit
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assumerole_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "audit_user_policy" {
  for_each   = var.audit_policy_arns
  provider   = aws.audit
  role       = aws_iam_role.audit_user_role[0].name
  policy_arn = each.value
}

##
# Bastion account
#
resource "aws_iam_role" "bastion_user_role" {
  count              = signum(length(var.bastion_policy_arns))
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assumerole_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "bastion_user_policy" {
  for_each   = var.bastion_policy_arns
  role       = aws_iam_role.bastion_user_role[0].name
  policy_arn = each.value
}

##
# Production account
#
resource "aws_iam_role" "production_user_role" {
  count              = signum(length(var.production_policy_arns))
  provider           = aws.production
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assumerole_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "production_user_policy" {
  for_each   = var.production_policy_arns
  provider   = aws.production
  role       = aws_iam_role.production_user_role[0].name
  policy_arn = each.value
}
