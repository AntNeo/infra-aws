variable "bucket_name" {
  type        = string
  description = "The bucket name you want to create"
}

variable "region" {
  type        = string
  description = "The region of bucket you want to create"
  default     = "eu-west-1"
}

variable "domain_name" {
  type        = string
  description = "domain name you want to use in cloudfront"
}


variable "sub_domain" {
  type        = string
  description = "sub-domain name you want to use in cloudfront"
}
