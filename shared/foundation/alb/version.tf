terraform {
  required_version = ">= 1.0"

   required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.59"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
   }
  backend "s3" {
    key = "shared/alb.tfstate" 
    bucket = "641593750485-terraform-states"
    region = "ap-southeast-2"
  }
}
