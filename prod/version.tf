terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.37"
    }
  }

  backend "s3" {
    key    = "prod/terraform.tfstate"
    bucket = "975049907995-terraform-states"
    region = "ap-southeast-2"
  }
}
