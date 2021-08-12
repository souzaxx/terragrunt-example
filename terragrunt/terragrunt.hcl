locals {
  folders     = split("/", path_relative_to_include())
  global_vars = yamldecode(file("global.yaml"))
  env_vars    = yamldecode(file(format("%s/%s", local.folders[0], "env.yaml")))
  region_vars = yamldecode(file(format("%s/%s/%s", local.folders[0], local.folders[1], "region.yaml")))
  common_tags = merge(local.global_vars.tags, local.env_vars.tags, local.region_vars.tags)
}

generate "provider" {
  path      = "auto_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region_vars.aws_region}"
      default_tags {
        tags = {
          ${yamlencode(local.common_tags)}
        }
      } 
    }
  EOF
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "terragrunt-sample-envs"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terragrunt-sample-state-lock"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
