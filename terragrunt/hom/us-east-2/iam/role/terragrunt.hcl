terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-role?ref=v4.2.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
}

inputs = {

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role             = true
  create_instance_profile = true

  role_name         = "webserver-${local.env_vars.env}"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}
