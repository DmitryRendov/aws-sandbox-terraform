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
