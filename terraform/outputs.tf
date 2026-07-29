# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------

output "nginx_security_group_id" {
  description = "ID of the Nginx security group"
  value       = module.security.nginx_sg_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.app_sg_id
}

# -----------------------------------------------------------------------------
# Compute Outputs
# -----------------------------------------------------------------------------

output "nginx_public_ip" {
  description = "Public IP of the Nginx reverse proxy"
  value       = module.ec2.nginx_public_ip
}

output "app_private_ip" {
  description = "Private IP of the application server"
  value       = module.ec2.app_private_ip
}

output "nginx_instance_id" {
  description = "Instance ID of the Nginx server"
  value       = module.ec2.nginx_instance_id
}

output "app_instance_id" {
  description = "Instance ID of the application server"
  value       = module.ec2.app_instance_id
}
