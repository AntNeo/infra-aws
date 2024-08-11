variable "domain_name" {
  description = "The domain name for which the certificate should be issued"
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "infra_vpc_name" {
  description = "vpc name of infra"
  type        = string
  default     = "my-vpc"
}
