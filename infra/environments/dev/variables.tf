# WHY THIS FILE EXISTS: Input variables for the dev environment.
# All sensitive values (passwords, secrets) come from GitHub Actions secrets,
# not from this file. Never commit sensitive values here.

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resource names"
  type        = string
  default     = "webapp"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to deploy into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "webapp"
}

variable "db_username" {
  description = "PostgreSQL database username"
  type        = string
  default     = "webapp"
}

variable "backend_image" {
  description = "ECR repository URI for the backend image"
  type        = string
}

variable "backend_image_tag" {
  description = "Docker image tag to deploy for the backend"
  type        = string
}

variable "frontend_image" {
  description = "ECR repository URI for the frontend image"
  type        = string
}

variable "frontend_image_tag" {
  description = "Docker image tag to deploy for the frontend"
  type        = string
}
