# output "ecs_cluster_id" {
#   description = "The ID of the Jenkins EC2 instance"
#   value       = module.ecs.outputs.ecs_cluster_id
# }
output "jenkins_aws_access_key_id" {
  value     = aws_iam_access_key.jenkins_access_key.id
  sensitive = true
}

output "jenkins_aws_secret_access_key" {
  value     = aws_iam_access_key.jenkins_access_key.secret
  sensitive = true
}

output "db_group" {
  value = module.uatvpc.database_subnet_group
}
