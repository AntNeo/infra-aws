provider "aws" {
  region = var.aws_region
}
# define Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-cluster"
}

# define Task
# data "template_file" "template_container_definitions" {
#   template = file("container-definitions.json.tpl")

#   vars = {
#     app_image      = var.app_image
#     fargate_cpu    = var.fargate_cpu
#     fargate_memory = var.fargate_memory
#     aws_region     = var.aws_region
#     app_port       = var.container_port
#   }
# }

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name_prefix}-task"
  execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = templatefile("${path.module}/container-definitions.json.tpl", {
    app_image      = var.app_image
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    app_port       = var.container_port
  })
}

# define Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = var.min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks_sg.id}"]
    subnets          = var.vpc_private_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    container_name   = var.balanced_container_name
    container_port   = var.container_port
  }

}


# define tg
resource "aws_alb_target_group" "alb_target_group" {
  name        = "${var.name_prefix}-alb-target-group"
  port        = var.container_port
  protocol    = var.alb_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    timeout             = "3"
    interval            = "5"
    protocol            = var.alb_protocol
    matcher             = "200"
    path                = var.healthcheck_path
  }
}

# define Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.name_prefix}"

  tags = {
    Name = "antoneo-api"
  }
}

# define Log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.name_prefix}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}


# ECS tasks security group
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "${var.name_prefix}-ecs-tasks-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
