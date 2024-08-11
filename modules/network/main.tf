module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.12"

  name = var.name

  cidr = var.cidr

  public_subnets = var.public_subnets

  # single nat gageway
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  
}