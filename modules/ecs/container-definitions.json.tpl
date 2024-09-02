[
  {
    "cpu": ${fargate_cpu},
    "essential": true,
    "image": "${app_image}",
    "memory": ${fargate_memory},
    "name": "antoneo-api",
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${prefix}-awslogs-api",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "awslogs-api"
        }
    },
    "environmentFiles": [
        {
            "value": "${s3_bucket}/env/.env",
            "type": "s3"
        }
    ]
  }
]