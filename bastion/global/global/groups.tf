##
# Ops
#
resource "aws_iam_group" "ops" {
  name = "ops"
}

resource "aws_iam_group_membership" "ops" {
  name = "ops-group-membership"

  users = [
    module.dmitry_rendov.name,
  ]

  group = aws_iam_group.ops.name
}

resource "aws_iam_group_policy_attachment" "ops_assumerole_all" {
  group      = aws_iam_group.ops.name
  policy_arn = aws_iam_policy.assumerole_all.arn
}

##
# Developers
#
resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers-group-membership"

  users = [
    module.dmitry_rendov.name,
  ]

  group = aws_iam_group.developers.name
}

##
# Sandbox
#
resource "aws_iam_group" "sandbox" {
  name = "sandbox"
}

resource "aws_iam_group_policy_attachment" "force_mfa" {
  group      = aws_iam_group.sandbox.name
  policy_arn = aws_iam_policy.force_mfa.arn
}
