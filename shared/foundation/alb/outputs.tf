output "alb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.id
}

output "alb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = module.alb.arn_suffix
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.alb.zone_id
}

output "alb_listener" {
  description = "The id of infra vpc"
  value       = module.alb.listeners
}

output "route53_zone_id" {
  description = "The zone_id of the domain dns zone"
  value       = data.aws_route53_zone.this.zone_id
}


output "vpc_id" {
  description = "The id of infra vpc"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The id of infra vpc"
  value       = module.vpc.private_subnets
}
