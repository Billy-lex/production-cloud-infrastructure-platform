# -----------------------------------------------------------------------------
# Dev Environment - Root Module
#
# Orchestrates VPC, Security, and EC2 modules to provision
# the full infrastructure stack for the dev environment.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Modules
# -----------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  enable_nat_gateway  = var.enable_nat_gateway
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

module "ec2" {
  source = "../../modules/ec2"

  project_name         = var.project_name
  environment          = var.environment
  public_subnet_id     = module.vpc.public_subnet_id
  private_subnet_id    = module.vpc.private_subnet_id
  nginx_sg_id          = module.security.nginx_sg_id
  app_sg_id            = module.security.app_sg_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = module.security.ec2_instance_profile_name
}
