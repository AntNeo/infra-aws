provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    managedBy = "terraform"
    usedFor   = "jenkins"
  }
}

# Read ALB state
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "975049907995-terraform-states"
    key    = "shared/alb.tfstate"
    region = var.region
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Create admin password
resource "random_password" "jenkins_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_security_group" "jenkins_sg" {
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

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "jenkins_sg" })
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  subnet_id              = data.terraform_remote_state.infra.outputs.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = templatefile("${path.module}/jenkins-master.sh", {
    jenkins_home     = "/var/jenkins_home"
    jenkins_admin    = var.jenkins_user
    jenkins_password = random_password.jenkins_admin_password.result
  })

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  lifecycle {
    ignore_changes = [ ami ]
  }
  
  tags = merge(local.common_tags, { Name = "JenkinsMaster" })
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}




##################################################################
# Create ALB target group and rule
##################################################################
resource "aws_lb_target_group" "jenkins_tg" {
  name        = "jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/whoAmI/api/json"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = merge(local.common_tags, { Name = "jenkins-tg" })
}

resource "aws_lb_listener_rule" "jenkins_forward" {
  listener_arn = data.terraform_remote_state.infra.outputs.alb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    host_header {
      values = ["jenkins.*"]
    }
  }
}


resource "aws_lb_target_group_attachment" "jenkins_attachment" {
  target_group_arn = resource.aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 8080
}

resource "aws_route53_record" "jenkins_record" {
  zone_id = data.terraform_remote_state.infra.outputs.route53_zone_id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.infra.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.infra.outputs.alb_zone_id
    evaluate_target_health = true
  }

}



# resource "aws_secretsmanager_secret" "jenkins_admin_secret" {
#   name        = "jenkins-admin-password-${var.secret_subffix}"
#   description = "Jenkins admin secret for user ${var.jenkins_user}"

#   tags = merge(local.common_tags, { Name = "JenkinsAdminSecret" })
# }

# resource "aws_secretsmanager_secret_version" "jenkins_agent_secret_version" {
#   secret_id = aws_secretsmanager_secret.jenkins_admin_secret.id
#   secret_string = jsonencode({
#     jenkins_user     = "${var.jenkins_user}"
#     jenkins_password = random_password.jenkins_admin_password.result
#   })
# }
