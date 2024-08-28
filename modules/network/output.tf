output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The id of infra vpc"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The id of infra vpc"
  value       = module.vpc.public_subnets
}

output "private_subnets_rts" {
  value = module.vpc.private_route_table_ids
}

output "public_subnets_rt" {
  value = module.vpc.public_route_table_ids
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}
