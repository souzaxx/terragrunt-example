terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.0.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}


inputs = {
  name = "vpc-${local.env_vars.env}"
  cidr = "10.240.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.240.0.0/24"]
  public_subnets  = ["10.240.201.0/24", "10.240.202.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}
