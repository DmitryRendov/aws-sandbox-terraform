resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "default"
  role_arn = aws_iam_role.awsconfig.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.record_global_resources
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "awsconfig" {
  name        = "${module.config_label.id}-role"
  description = "Role for AWS Config recorder to assume"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = module.config_label.tags
}

resource "aws_iam_role_policy_attachment" "AWSConfig" {
  role       = aws_iam_role.awsconfig.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "config_recorder" {
  name           = "default"
  s3_bucket_name = var.s3_bucket_name
  depends_on     = [aws_config_configuration_recorder.config_recorder]

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }
}

resource "aws_config_configuration_recorder_status" "config_recorder" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = var.config_recorder_enabled
  depends_on = [aws_config_delivery_channel.config_recorder]
}
