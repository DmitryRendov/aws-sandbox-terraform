locals {
  count = var.enabled ? 1 : 0
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.services
    }
  }
}

resource "aws_iam_role" "role" {
  count              = local.count
  name               = var.label.id
  assume_role_policy = data.aws_iam_policy_document.default.json
  tags               = var.label.tags
}
