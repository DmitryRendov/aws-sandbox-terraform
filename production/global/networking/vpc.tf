module "vpc" {
  source = "../../../modules/base/vpc/v1/vpc"
  cidr   = "10.100.0.0/16"
  label  = module.label
}

module "subnets" {
  source = "../../../modules/base/vpc/v1/subnets"

  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.100.0.0/20", "10.100.16.0/20"]
  private_subnets    = ["10.100.32.0/20", "10.100.48.0/20"]
  enable_nat_gateway = false
  single_nat_gateway = true

  label = module.label
}
