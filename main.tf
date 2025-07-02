terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

# VPC
resource "aws_vpc" "im_example_ecs" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = coalesce(var.vpc_name, "${var.name_prefix}-vpc")
    }
}

# Public Subnet 1
resource "aws_subnet" "im_example_ecs_a" {
    vpc_id                  = aws_vpc.im_example_ecs.id
    cidr_block              = var.subnet_cidr_a
    map_public_ip_on_launch = true
    availability_zone       = var.availability_zone_a
    tags = {
        Name = coalesce(var.subnet_name_a, "${var.name_prefix}-public-subnet-a")
    }
}

# Public Subnet 2
resource "aws_subnet" "im_example_ecs_b" {
    vpc_id                  = aws_vpc.im_example_ecs.id
    cidr_block              = var.subnet_cidr_b
    map_public_ip_on_launch = true
    availability_zone       = var.availability_zone_b
    tags = {
        Name = coalesce(var.subnet_name_b, "${var.name_prefix}-public-subnet-b")
    }
}

# Internet Gateway
resource "aws_internet_gateway" "im_example_ecs" {
    vpc_id = aws_vpc.im_example_ecs.id
    tags = {
        Name = coalesce(var.igw_name, "${var.name_prefix}-igw")
    }
}

# Route Table
resource "aws_route_table" "im_example_ecs" {
    vpc_id = aws_vpc.im_example_ecs.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.im_example_ecs.id
    }
    tags = {
        Name = coalesce(var.rt_name, "${var.name_prefix}-rt")
    }
}

# Route Table Association
resource "aws_route_table_association" "im_example_ecs_a" {
    subnet_id      = aws_subnet.im_example_ecs_a.id
    route_table_id = aws_route_table.im_example_ecs.id
}

resource "aws_route_table_association" "im_example_ecs_b" {
    subnet_id      = aws_subnet.im_example_ecs_b.id
    route_table_id = aws_route_table.im_example_ecs.id
}

# Security Group for ECS
resource "aws_security_group" "im_ecs" {
    name        = coalesce(var.ecs_sg_name, "${var.name_prefix}-ecs-sg")
    description = "Allow HTTP inbound traffic from ALB"
    vpc_id      = aws_vpc.im_example_ecs.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = coalesce(var.ecs_sg_name, "${var.name_prefix}-ecs-sg")
    }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = coalesce(var.alb_sg_name, "${var.name_prefix}-alb-sg")
  description = "Allow HTTP inbound traffic to ALB"
  vpc_id      = aws_vpc.im_example_ecs.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = coalesce(var.alb_sg_name, "${var.name_prefix}-alb-sg")
  }
}

# Application Load Balancer
resource "aws_lb" "nginx_alb" {
  name               = coalesce(var.alb_name, "${var.name_prefix}-alb")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.im_example_ecs_a.id, aws_subnet.im_example_ecs_b.id]
  tags = {
    Name = coalesce(var.alb_name, "${var.name_prefix}-alb")
  }
}

# Target Group
resource "aws_lb_target_group" "nginx_tg" {
  name     = coalesce(var.tg_name, "${var.name_prefix}-tg")
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.im_example_ecs.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = coalesce(var.tg_name, "${var.name_prefix}-tg")
  }
}

# Listener
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "im_example_ecs" {
    name = coalesce(var.ecs_cluster_name, "${var.name_prefix}-ecs-cluster")
}

# ECR Repository
resource "aws_ecr_repository" "im_example_ecs" {
    name = coalesce(var.ecr_repo_name, "${var.name_prefix}-ecr-repo")
}

# ECS Task Execution Role
resource "aws_iam_role" "im_ecs_task_execution_role" {
    name = "im-ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "im_ecs_task_execution_role_policy" {
    role       = aws_iam_role.im_ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = coalesce(var.ecs_log_group_name, "/ecs/${var.name_prefix}-nginx")
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "im_example_ecs" {
    family                   = coalesce(var.ecs_task_family, "${var.name_prefix}-task")
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = aws_iam_role.im_ecs_task_execution_role.arn
    container_definitions    = jsonencode([{
        name      = "nginx"
        image     = "nginx:latest"
        essential = true
        portMappings = [{
            containerPort = 80
            hostPort      = 80
        }]
    command = ["/bin/sh", "-c", "echo \"<h1>Hello from ECS! $(hostname) $(pwd)</h1>\" > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "nginx"
          }
        }
    }])
}

# ECS Service
resource "aws_ecs_service" "im_example_ecs" {
    name            = coalesce(var.ecs_service_name, "${var.name_prefix}-ecs-service")
    cluster         = aws_ecs_cluster.im_example_ecs.id
    task_definition = aws_ecs_task_definition.im_example_ecs.arn
    desired_count   = 1
    launch_type     = "FARGATE"
    network_configuration {
        subnets          = [aws_subnet.im_example_ecs_a.id, aws_subnet.im_example_ecs_b.id]
        assign_public_ip = true
        security_groups  = [aws_security_group.im_ecs.id]
    }
    load_balancer {
      target_group_arn = aws_lb_target_group.nginx_tg.arn
      container_name   = "nginx"
      container_port   = 80
    }
    depends_on = [aws_ecs_cluster.im_example_ecs, aws_lb_listener.nginx_listener]
}
