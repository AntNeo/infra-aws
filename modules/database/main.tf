locals {
  common_tags = {
    managedBy = "terraform"
  }
}

resource "aws_db_instance" "my_rds" {
  instance_class              = var.instance_class
  engine                      = var.engine
  engine_version              = var.engine_version
  allocated_storage           = var.allocated_storage
  manage_master_user_password = var.manage_master_user_password
  username                    = var.username

  db_subnet_group_name = var.db_subnet_group_name

  license_model                 = "license-included"
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]

  tags = local.common_tags

  enabled_cloudwatch_logs_exports = ["agent", "error"]
}


##################
# vpc sg
##################
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# CloudWatch Log Group
################################################################################
resource "aws_cloudwatch_log_group" "this" {

  name = "/aws/rds/instance/${aws_db_instance.my_rds.identifier}/sqlserverlog"

  tags = local.common_tags
}
