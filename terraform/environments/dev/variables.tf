# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "production-cloud-platform"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-1a"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet outbound access (disable to save cost)"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for all servers"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances (leave empty to skip key assignment)"
  type        = string
  default     = ""
}
