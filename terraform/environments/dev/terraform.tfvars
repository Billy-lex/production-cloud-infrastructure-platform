# Dev environment specific values

project_name = "production-cloud-platform"
environment  = "dev"
aws_region   = "us-east-1"

# Network
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "us-east-1a"
enable_nat_gateway  = false

# Compute
instance_type = "t3.micro"
key_name      = ""
