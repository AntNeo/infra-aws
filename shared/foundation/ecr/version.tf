terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.37"
    }
  }

  backend "s3" {
    key = "shared/ecr.tfstate" 
    bucket = "641593750485-terraform-states"
    region = "ap-southeast-2"
  }
}
