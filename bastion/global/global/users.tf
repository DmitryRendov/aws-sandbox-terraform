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

### CI/CD ###

resource "aws_iam_user" "automation_user" {
  name          = local.automation_username
  path          = "/terraform/"
  force_destroy = true
  tags          = module.automation_user_label.tags
}

resource "aws_iam_user_policy_attachment" "automation_user_policies" {
  for_each   = local.automation_policies["automation_bastion_policy_arns"]
  user       = aws_iam_user.automation_user.name
  policy_arn = each.value
  depends_on = [
    aws_iam_policy.automation_permissions,
    aws_iam_policy.automation_secrets,
  ]
}

### Give Machine user power

data "aws_iam_policy_document" "automation_secrets" {
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:ResourceTag/role"
      values   = [local.automation_username]
    }

    condition {
      test     = "StringEquals"
      variable = "ssm:ResourceTag/environment"
      values   = [var.account_name]
    }

    effect = "Allow"
  }

  dynamic "statement" {
    for_each = aws_iam_user.automation_user.*.name
    content {
      actions   = ["ssm:GetParameter", "ssm:GetParameters"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "ssm:ResourceTag/username"
        values   = [statement.value]
      }
    }
  }

}

resource "aws_iam_policy" "automation_secrets" {
  name        = "${module.automation_user_label.id}-secrets"
  description = "Machine user policy to read its secrets"
  policy      = data.aws_iam_policy_document.automation_secrets.json
  tags        = module.automation_user_label.tags
}


### END CI/CD ##
