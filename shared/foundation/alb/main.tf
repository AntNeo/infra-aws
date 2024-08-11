provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.this.id
}

module "wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.this.id
}


locals {
  name = "alb-antonio-demo"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  common_tags = {
    managedBy = "terraform"
    usedFor   = "infra"
  }
}

##################################################################
# Network Infra
##################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.12.0"

  name = var.infra_vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(local.common_tags, { Name = "${var.infra_vpc_name}" })
}


##################################################################
# Application Load Balancer with minimum configuration
##################################################################

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    # set default action to plain response
    https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]

      fixed_response = {
        content_type = "text/plain"
        message_body = "middle of nowhere"
        status_code  = "200"
      }
    }

  }

  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  #   prefix = "access-logs"
  # }

  # connection_logs = {
  #   bucket  = module.log_bucket.s3_bucket_id
  #   enabled = true
  #   prefix  = "connection-logs"
  # }

  client_keep_alive = 7200

  # Route53 Record(s)
  route53_records = {
    A = {
      name    = local.name
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }
    AAAA = {
      name    = local.name
      type    = "AAAA"
      zone_id = data.aws_route53_zone.this.id
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name}" })
}
