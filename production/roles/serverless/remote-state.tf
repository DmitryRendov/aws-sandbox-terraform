data "terraform_remote_state" "bastion_global" {
  backend = "s3"

  config = {
    key          = "bastion/global/global"
    bucket       = var.terraform_remote_state_bucket
    region       = var.terraform_remote_state_region
    profile      = "sts"
    role_arn     = "arn:aws:iam::${var.aws_account_map["bastion"]}:role/${var.terraform_exec_role}"
    session_name = "terraform"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"

  config = {
    key          = "${var.account_name}/global/global"
    bucket       = var.terraform_remote_state_bucket
    region       = var.terraform_remote_state_region
    profile      = "sts"
    role_arn     = "arn:aws:iam::${var.aws_account_map["bastion"]}:role/${var.terraform_exec_role}"
    session_name = "terraform"
  }
}

data "terraform_remote_state" "global_infra" {
  backend = "s3"

  config = {
    key          = "${var.account_name}/roles/global-infra"
    bucket       = var.terraform_remote_state_bucket
    region       = var.terraform_remote_state_region
    profile      = "sts"
    role_arn     = "arn:aws:iam::${var.aws_account_map["bastion"]}:role/${var.terraform_exec_role}"
    session_name = "terraform"
  }
}
