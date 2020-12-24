data "terraform_remote_state" "core" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    key          = "${var.account_name}/roles/core"
    bucket       = var.tf_remote_state_s3_storage_bucket
    region       = var.tf_remote_state_s3_storage_region
    profile      = "sts"
    role_arn     = "arn:aws:iam::${var.aws_account_map["production"]}:role/${var.terraform_exec_role}"
    session_name = "terraform"
  }
}
