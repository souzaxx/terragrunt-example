terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v2.19.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  env_vars = yamldecode(file(find_in_parent_folders("env.yaml")))

  webpage    = base64encode(templatefile(find_in_parent_folders("files/template/index.html"), { env = local.env_vars.env }))
  nginx_conf = filebase64(find_in_parent_folders("files/template/hello.conf"))
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")

  mock_outputs = {
    vpc_id = "vpc-00000000"
    public_subnets = [
      "subnet-00000000",
      "subnet-00000001",
      "subnet-00000002",
    ]
  }
}

dependency "sg" {
  config_path = find_in_parent_folders("sg")

  mock_outputs = {
    this_security_group_id = "sg-00000000"
  }
}

dependency "ami" {
  config_path = find_in_parent_folders("ami")

  mock_outputs = {
    id = "ami-00000000000000000"
  }
}

dependency "role" {
  config_path = find_in_parent_folders("iam/role")

  mock_outputs = {
    iam_instance_profile_name = "mock_name"
  }
}


inputs = {

  name           = "webserver-${local.env_vars.env}"
  instance_count = 1

  ami                    = dependency.ami.outputs.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]
  subnet_ids             = dependency.vpc.outputs.public_subnets
  iam_instance_profile   = dependency.role.outputs.iam_instance_profile_name
  user_data_base64       = base64encode(templatefile(find_in_parent_folders("files/script/user_data.sh"), { nginx_conf = local.nginx_conf, webpage = local.webpage }))

}
