output "nginx_alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer for NGINX"
  value       = aws_lb.nginx_alb.dns_name
}
