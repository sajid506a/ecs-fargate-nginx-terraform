# AWS ECS NGINX Terraform Example

This project provisions a highly-available AWS ECS Fargate service running the official NGINX Docker image, fronted by an Application Load Balancer (ALB), using Terraform.

## Features
- VPC with two public subnets across different Availability Zones
- Internet Gateway and public route table
- Security groups for ECS and ALB
- Application Load Balancer (ALB) with HTTP listener
- Target group for ECS tasks
- ECS Cluster, Task Definition, and Service (Fargate)
- CloudWatch Log Group for ECS container logs
- ECR repository (optional, not used by default NGINX)
- All resource names are configurable via variables

## Usage

1. **Clone this repo and change directory:**
   ```sh
   git clone <repo-url>
   cd <project-directory>
   ```

2. **Initialize Terraform:**
   ```sh
   terraform init
   ```

3. **Review and apply the plan:**
   ```sh
   terraform plan
   terraform apply
   ```

4. **Access your NGINX service:**
   - After apply, Terraform will output the ALB DNS name (see `nginx_alb_dns_name` in outputs).
   - Open the DNS name in your browser to see the NGINX welcome page.

## Variables
- `name_prefix`: Prefix for all resource names (default: `dev`)
- `aws_region`: AWS region (default: `us-east-1`)
- `subnet_cidr_a`, `subnet_cidr_b`: CIDR blocks for public subnets
- `availability_zone_a`, `availability_zone_b`: AZs for public subnets
- `ecs_log_group_name`: CloudWatch log group name for ECS logs
- ...and more (see `variables.tf`)

## Logging
- ECS container logs are sent to CloudWatch Logs (log group configurable).

## Cleanup
To destroy all resources:
```sh
terraform destroy
```

## Notes
- If you see errors about resources already existing, import them into Terraform using `terraform import`.
- Make sure your AWS credentials are configured (e.g., via `aws configure`).
- The default NGINX container is used; customize the task definition for your own images if needed.

---

**Author:** Your Name
