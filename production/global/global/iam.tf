### CI/CD ###

resource "aws_iam_user" "machine_user" {
  name          = local.machine_user_name
  path          = "/terraform/"
  force_destroy = true
  tags          = module.machine_user_label.tags
}

### Give Machine user power

data "aws_iam_policy_document" "machine_secrets" {
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:ResourceTag/role"
      values   = [local.machine_user_name]
    }

    condition {
      test     = "StringEquals"
      variable = "ssm:ResourceTag/environment"
      values   = [var.account_name]
    }

    effect = "Allow"
  }

  dynamic "statement" {
    for_each = aws_iam_user.machine_user.*.name
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

resource "aws_iam_policy" "machine_secrets" {
  name        = "machine-secrets"
  description = "Machine user policy to read its secrets"
  policy      = data.aws_iam_policy_document.machine_secrets.json
  tags        = module.machine_user_label.tags
}

resource "aws_iam_group_policy_attachment" "machine_secrets" {
  group      = "automation"
  policy_arn = aws_iam_policy.machine_secrets.arn
}

### END CI/CD ##

### AUTOMATION ###

resource "aws_iam_group" "automation" {
  name = "automation"
  path = "/terraform/"
}

resource "aws_iam_group_membership" "automation" {
  name  = "automation"
  users = [aws_iam_user.machine_user.name]
  group = aws_iam_group.automation.name
}

resource "aws_iam_group_policy_attachment" "read_only_access" {
  group      = "automation"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "machine_assumerole_terraform_github" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_map["bastion"]}:root",
        aws_iam_user.machine_user.arn,
        "arn:aws:iam::${var.aws_account_map["production"]}:role/ops",
      ]
    }
  }
}

resource "aws_iam_role" "terraform_github" {
  name               = "terraform-github-state-editor"
  path               = "/terraform/"
  assume_role_policy = data.aws_iam_policy_document.machine_assumerole_terraform_github.json
  tags               = module.label.tags
}

data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_remote_state_bucket}",
      "arn:aws:s3:::${var.terraform_remote_state_bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Put*",
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_remote_state_bucket}/github",
      "arn:aws:s3:::${var.terraform_remote_state_bucket}/github/*",
    ]
  }
}

resource "aws_iam_role_policy" "terraform_github_state_editor" {
  name   = "terraform-github-state-bucket-rw"
  role   = aws_iam_role.terraform_github.id
  policy = data.aws_iam_policy_document.terraform_state_access.json
}

### END AUTOMATION ###
