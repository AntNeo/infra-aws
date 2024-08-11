resource "aws_security_group" "jenkins_agent_sg" {
  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "jenkins_agent_sg" })
}

# data "aws_secretsmanager_secret_version" "jenkins_admin_secret" {
#   secret_id = aws_secretsmanager_secret.jenkins_admin_secret.id
# }

resource "aws_instance" "jenkins_agent" {
  count                  = var.agent_instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.agent_instance_type
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = data.terraform_remote_state.infra.outputs.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]

  user_data = templatefile("${path.module}/jenkins-agent.sh", {
    jenkins_url = "http://${aws_instance.jenkins_master.private_dns}:8080",
    agent_name  = "JenkinsAgent-${count.index}",
    username    = var.jenkins_user,
    password    = random_password.jenkins_admin_password.result
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = merge(local.common_tags, { Name = "JenkinsAgent-${count.index}" })

  depends_on = [aws_instance.jenkins_master]

  lifecycle {
    ignore_changes = [ami]
  }
}


