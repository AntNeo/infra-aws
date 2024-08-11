variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}

variable "route53_record_name" {
  description = "Route 53 Record Name"
  type        = string
}


variable "agent_instance_count" {
  description = "Number of Jenkins agent instances"
  type        = number
  default     = 2
}

variable "secret_subffix" {
  description = "secret will not destoy within 7days, so we need to add a subffix if we need to rebuild the infra"
  type        = number
  default     = 1
}


variable "agent_instance_type" {
  description = "EC2 instance type for Jenkins agents"
  type        = string
  default     = "t2.micro"
}


variable "jenkins_user" {
  description = "Prefix for the secrets stored in AWS Secrets Manager"
  type        = string
  default     = "jenkins"
}
