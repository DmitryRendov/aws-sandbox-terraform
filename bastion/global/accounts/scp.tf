# Note about SCP Quotas:
# max size of SCP policy doc: 5120 bytes
# max attached to root: 5

data "aws_iam_policy_document" "scp" {
  source_policy_documents = [
    data.aws_iam_policy_document.deny_disallowed_regions.json,
    data.aws_iam_policy_document.deny_iam_create_access_key.json,
    data.aws_iam_policy_document.deny_root_access.json,
    data.aws_iam_policy_document.deny_org_leave.json,
    data.aws_iam_policy_document.immutable_admin_role.json,
    data.aws_iam_policy_document.protect_iam_roles.json,
  ]
}

resource "aws_organizations_policy" "scp" {
  name        = "Main"
  description = "Main SCP policy"
  content     = data.aws_iam_policy_document.scp.json
}

output "scp_result" {
  value = data.aws_iam_policy_document.scp.json
}

