variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}
