# WHY THIS FILE EXISTS: Root Terraform configuration for the production environment.
# Production differs from dev in: instance sizes, multi-AZ, enhanced monitoring,
# deletion protection, and stricter security groups.
# Changes here require a Terraform plan review before apply — never auto-apply to prod.

terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = "prod"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "rds" {
  source = "../../modules/rds"

  project_name      = var.project_name
  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  instance_class    = "db.t3.medium"
  multi_az          = true   # Required in prod
  db_name           = var.db_name
  db_username       = var.db_username
  db_password_arn   = module.secrets.db_password_arn
  deletion_protection = true # Prevent accidental deletion
}

module "secrets" {
  source = "../../modules/secrets-manager"

  project_name = var.project_name
  environment  = "prod"
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = "prod"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  backend_image      = var.backend_image
  backend_image_tag  = var.backend_image_tag
  db_url             = "jdbc:postgresql://${module.rds.endpoint}/${var.db_name}"
  db_secret_arn      = module.secrets.db_password_arn
  frontend_origin    = "https://${module.s3_cloudfront.cloudfront_domain}"
  task_cpu           = 1024
  task_memory        = 2048
  desired_count      = 2   # Minimum 2 for high availability
}

module "s3_cloudfront" {
  source = "../../modules/s3-cloudfront"

  project_name       = var.project_name
  environment        = "prod"
  frontend_image     = var.frontend_image
  frontend_image_tag = var.frontend_image_tag
  backend_api_url    = "https://${module.ecs.alb_dns_name}"
}
