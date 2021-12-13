# This file is for Service Control Policies within the bastion organization. You can
# then attach these policies to other accounts using the aws-organization-account module.

# This policy is to deny disallowed Regions in the organization
data "aws_iam_policy_document" "deny_disallowed_regions" {
  statement {
    sid = "DenyDisallowedRegions"

    not_actions = [
      "a4b:*",
      "acm:*",
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "awsbillingconsole:*",
      "budgets:*",
      "ce:*",
      "chime:*",
      "cloudfront:*",
      "config:*",
      "cur:*",
      "directconnect:*",
      "ec2:DescribeRegions",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVpnGateways",
      "fms:*",
      "globalaccelerator:*",
      "health:*",
      "iam:*",
      "importexport:*",
      "kms:*",
      "mobileanalytics:*",
      "networkmanager:*",
      "organizations:*",
      "pricing:*",
      "route53:*",
      "route53domains:*",
      "s3:GetAccountPublic*",
      "s3:ListAllMyBuckets",
      "s3:ListBuckets",
      "s3:PutAccountPublic*",
      "shield:*",
      "sts:*",
      "support:*",
      "trustedadvisor:*",
      "waf-regional:*",
      "waf:*",
      "wafv2:*",
      "wellarchitected:*",
    ]

    resources = ["*"]

    effect = "Deny"

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = var.allowed_regions
    }
  }
}

