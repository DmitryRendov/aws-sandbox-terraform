data "aws_iam_policy_document" "bastion_assumerole_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

output "bastion_assumerole_policy_json" {
  value = data.aws_iam_policy_document.bastion_assumerole_policy.json
}

data "aws_iam_policy_document" "assumerole_all" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "Null"
      variable = "aws:MultiFactorAuthAge"
      values   = ["false"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"
      values   = ["43200"]
    }
  }

  statement {
    sid = "2"

    actions = [
      "sts:GetSessionToken",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "assumerole_all" {
  name        = "${var.environment}-assumerole-all"
  description = "Grants a user the ability to assume all roles and fetch session tokens"
  policy      = data.aws_iam_policy_document.assumerole_all.json
}

data "aws_iam_policy_document" "force_mfa" {
  statement {
    sid = "AllowAllUsersToListAccounts"

    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
      "iam:ListUsers",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"

    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:DeleteSSHPublicKey",
      "iam:DeleteSigningCertificate",
      "iam:GetAccessKeyLastUsed",
      "iam:GetLoginProfile",
      "iam:GetSSHPublicKey",
      "iam:ListAccessKeys",
      "iam:ListSSHPublicKeys",
      "iam:ListSigningCertificates",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:UpdateSSHPublicKey",
      "iam:UpdateSigningCertificate",
      "iam:UploadSSHPublicKey",
      "iam:UploadSigningCertificate",
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
    ]
  }

  statement {
    sid = "AllowIndividualUserToListOnlyTheirOwnMFA"

    actions = [
      "iam:ListVirtualMFADevices",
      "iam:ListMFADevices",
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:mfa/*",
      "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
    ]
  }

  statement {
    sid    = "AllowIndividualUserToManageTheirOwnMFA"
    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
    ]
  }

  statement {
    sid = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"

    actions = [
      "iam:DeactivateMFADevice",
    ]

    resources = [
      "arn:aws:iam::${var.aws_account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
    ]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid    = "BlockMostAccessUnlessSignedInWithMFA"
    effect = "Deny"

    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetAccountSummary",
      "iam:ListAccessKeys",
      "iam:ListAccountAliases",
      "iam:ListMFADevices",
      "iam:ListSSHPublicKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "force_mfa" {
  name        = "ForceMFA"
  description = "Forces a user to use a MFA for all actions except managing their own MFA"
  policy      = data.aws_iam_policy_document.force_mfa.json
}

data "aws_iam_policy_document" "developer_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    not_resources = [
      "arn:aws:lambda:*:*:function:aws-sandbox-serverless*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutAclObject",
    ]

    resources = [
      "arn:aws:s3:::sb-production-serverless*",
      "arn:aws:s3:::sb-production-serverless*/*",
    ]
  }

  statement {
    actions   = ["ssm:*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ssm:ResourceTag/team"
      values   = ["$${aws:PrincipalTag/team}"]
    }

    effect = "Allow"
  }

  statement {
    actions   = ["ssm:*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "ssm:ResourceTag/username"
      values   = ["$${aws:PrincipalTag/username}"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "developer_permissions" {
  provider = aws.production
  name     = module.developer_label.id
  policy   = data.aws_iam_policy_document.developer_permissions.json
}

data "aws_iam_policy_document" "ops_role_iam" {
  statement {
    sid = "AllowOpsTerraformStates"
    actions = [
      "s3:DeleteObject",
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "arn:aws:s3:::mob-terraform-state/",
      "arn:aws:s3:::mob-terraform-state/*",
    ]
  }
}

resource "aws_iam_policy" "ops_bastion_role_iam" {
  name        = "bastion-role-ops-extras"
  description = "Extra permissions for the ops role in the bastion account"
  policy      = data.aws_iam_policy_document.ops_role_iam.json
  tags        = merge(module.label.tags, { Name = "${module.label.id} - Terraform State bucket access" })
}

data "aws_iam_policy_document" "deactivated_permissions" {
  statement {
    effect = "Deny"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "deactivated_user" {
  name   = module.deactivated_label.id
  policy = data.aws_iam_policy_document.deactivated_permissions.json
}

### AUTOMATION ###

resource "aws_iam_policy" "automation_permissions" {
  name   = module.automation_user_label.id
  policy = data.aws_iam_policy_document.automation_permissions.json
}

data "aws_iam_policy_document" "automation_permissions" {
  statement {
    sid = "AllowAutomationMOBBucket"
    actions = [
      "s3:DeleteObject",
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "arn:aws:s3:::mob-server-backups/",
      "arn:aws:s3:::mob-server-backups/*",
    ]
  }
}



### END AUTOMATION ###
