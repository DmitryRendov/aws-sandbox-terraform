# Deny ability to leave Organization
data "aws_iam_policy_document" "deny_org_leave" {
  statement {
    sid = "DenyOrgLeave"

    actions = [
      "organizations:LeaveOrganization"
    ]

    resources = [
      "*"
    ]

    effect = "Deny"

  }
}

