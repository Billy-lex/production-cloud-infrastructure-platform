variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for Nginx"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet for application server"
  type        = string
}

variable "nginx_sg_id" {
  description = "Security group ID for Nginx"
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for application server"
  type        = string
}

variable "instance_type" {
  description = "Default EC2 instance type"
  type        = string
}

variable "nginx_instance_type" {
  description = "Instance type for Nginx (overrides instance_type if set)"
  type        = string
  default     = ""
}

variable "app_instance_type" {
  description = "Instance type for app server (overrides instance_type if set)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "app_fixed_private_ip" {
  description = "Fixed private IP for the app server (used by Nginx user_data to avoid circular dependency)"
  type        = string
  default     = "10.0.2.10"
}
