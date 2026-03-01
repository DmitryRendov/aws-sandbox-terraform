resource "aws_ecr_repository" "default" {
  name = "${var.namespace}/${var.name}"
  tags = var.label.tags

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = data.template_file.rules.rendered
}

data "aws_iam_policy_document" "cross_account_get_access" {
  count = signum(length(var.cross_accounts))

  statement {
    sid = "AllowXAccountPush"

    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetrepositoryPolicy",
      "ecr:ListImages"
    ]

    principals {
      type = "AWS"

      identifiers = formatlist("arn:aws:iam::%s:root", var.cross_accounts)
    }
  }
  statement {
    sid = "LambdaECRImageRetrievalPolicy"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:SetRepositoryPolicy",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_ecr_repository_policy" "cross_account_get_access" {
  count      = signum(length(var.cross_accounts))
  repository = aws_ecr_repository.default.id
  policy     = data.aws_iam_policy_document.cross_account_get_access[0].json
}
