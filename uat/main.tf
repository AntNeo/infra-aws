provider "aws" {
  region = var.region
}

locals {
  # account_id = data.aws_caller_identity.current.account_id

  tags = {
    managedBy = "terraform"
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "641593750485-terraform-states"
    key    = "shared/alb.tfstate"
    region = var.region
  }
}


module "ecs" {
  source              = "..//modules/ecs"
  vpc_id              = data.terraform_remote_state.infra.outputs.vpc_id
  vpc_private_subnets = data.terraform_remote_state.infra.outputs.private_subnets
}
