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
  cidr = "192.168.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["192.168.0.0/24"]
  public_subnets  = ["192.168.101.0/24", "192.168.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}
