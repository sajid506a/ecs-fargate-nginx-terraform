variable "name_prefix" {
  description = "Prefix for all resource names (e.g., prod, dev, test)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_a" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_cidr_b" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_a" {
  description = "Availability zone for the first subnet"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "Availability zone for the second subnet"
  type        = string
  default     = "us-east-1b"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
  default     = null
}

variable "subnet_name_a" {
  description = "Name tag for the first public subnet"
  type        = string
  default     = null
}

variable "subnet_name_b" {
  description = "Name tag for the second public subnet"
  type        = string
  default     = null
}

variable "igw_name" {
  description = "Name tag for the internet gateway"
  type        = string
  default     = null
}

variable "rt_name" {
  description = "Name tag for the route table"
  type        = string
  default     = null
}

variable "ecs_sg_name" {
  description = "Name tag for the ECS security group"
  type        = string
  default     = null
}

variable "ecs_cluster_name" {
  description = "Name for the ECS cluster"
  type        = string
  default     = null
}

variable "ecr_repo_name" {
  description = "Name for the ECR repository"
  type        = string
  default     = null
}

variable "ecs_task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = null
}

variable "ecs_service_name" {
  description = "Name for the ECS service"
  type        = string
  default     = null
}

variable "alb_sg_name" {
  description = "Name tag for the ALB security group"
  type        = string
  default     = null
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
  default     = null
}

variable "tg_name" {
  description = "Name for the Target Group"
  type        = string
  default     = null
}

variable "ecs_log_group_name" {
  description = "Name for the CloudWatch Log Group for ECS logs"
  type        = string
  default     = null
}
