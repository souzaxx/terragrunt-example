terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group//modules/http-80?ref=v3.18.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}


dependency "vpc" {
  config_path = find_in_parent_folders("vpc")

  mock_outputs = {
    vpc_id = "vpc-00000000"
  }
}


inputs = {

  name        = "webserver-${local.env_vars.env}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}
