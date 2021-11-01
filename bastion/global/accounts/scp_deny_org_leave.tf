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

resource "aws_organizations_policy" "immutable_admin_role" {
  name        = "DenyOrgLeave"
  description = "Deny ability to leave Organization"

  content = data.aws_iam_policy_document.deny_org_leave.json
}
