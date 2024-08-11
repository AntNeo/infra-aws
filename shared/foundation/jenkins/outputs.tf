output "jenkins_instance_id" {
  description = "The ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_master.id
}

output "jenkins_initial_password" {
  description = "The initial admin password for Jenkins"
  value       = aws_instance.jenkins_master.public_ip
  # To retrieve the initial password, you'll need to SSH into the instance
  # and run the command: sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
}

# output "jenkins_url" {
#   description = "The URL to access Jenkins"
#   value       = "http://${aws_route53_record.jenkins_record.name}"
# }

output "jenkins_agent_ids" {
  description = "The IDs of the Jenkins agent EC2 instances"
  value       = aws_instance.jenkins_agent[*].id
}

output "jenkins_admin_password" {
  description = "jenkins admin apssword for user jekins_user"
  sensitive   = true
  value       = random_password.jenkins_admin_password.result
}

output "private_key_pem" {
  description = "Private key in PEM format"
  value       = tls_private_key.generated_key.private_key_pem
  sensitive   = true
}

# output "jenkins_admin_secret" {
#   description = "The secrets for Jenkins agents"
#   value       = aws_secretsmanager_secret.jenkins_admin_secret.arn
# }
