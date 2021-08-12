provider "aws" {
  region = var.region
}

variable env {}
variable cidr {}
variable azs {}
variable region {}
variable private_subnets {}
variable public_subnets {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-${var.env}"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 3.0"

  name        = "webserver-${var.env}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "4.2.0"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  create_role             = true
  create_instance_profile = true

  role_name         = "webserver-${var.env}"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

locals {
  webpage = base64encode(templatefile("${path.module}/files/template/index.html", {env = var.env}))
  nginx_conf = filebase64("${path.module}/files/template/hello.conf")
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200430"]
  }
}

module "instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "webserver-${var.env}"
  instance_count = 1

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.security_group.this_security_group_id]
  subnet_ids             = module.vpc.public_subnets
  iam_instance_profile   = module.role.iam_instance_profile_name
  user_data_base64       = base64encode(templatefile("${path.module}/files/script/user_data.sh", { nginx_conf = local.nginx_conf, webpage = local.webpage }))

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}
