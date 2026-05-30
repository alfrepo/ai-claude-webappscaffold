# WHY THIS FILE EXISTS: Root Terraform configuration for the development environment.
# All AWS resources for dev are provisioned here by referencing shared modules.
# To add a new AWS service: create a module under infra/modules/ and reference it here.

terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — replace bucket/table with actual names
  backend "s3" {
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    # bucket is passed via -backend-config in CI (see deploy.yml)
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# ── VPC ───────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = "dev"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# ── RDS PostgreSQL ────────────────────────────────────────────────────────────
module "rds" {
  source = "../../modules/rds"

  project_name    = var.project_name
  environment     = "dev"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  instance_class  = "db.t3.micro"
  db_name         = var.db_name
  db_username     = var.db_username
  db_password_arn = module.secrets.db_password_arn
}

# ── Secrets Manager ───────────────────────────────────────────────────────────
module "secrets" {
  source = "../../modules/secrets-manager"

  project_name = var.project_name
  environment  = "dev"
}

# ── ECS (Backend) ─────────────────────────────────────────────────────────────
module "ecs" {
  source = "../../modules/ecs"

  project_name         = var.project_name
  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  backend_image        = var.backend_image
  backend_image_tag    = var.backend_image_tag
  db_url               = "jdbc:postgresql://${module.rds.endpoint}/${var.db_name}"
  db_secret_arn        = module.secrets.db_password_arn
  frontend_origin      = "https://${module.s3_cloudfront.cloudfront_domain}"
}

# ── S3 + CloudFront (Frontend) ────────────────────────────────────────────────
module "s3_cloudfront" {
  source = "../../modules/s3-cloudfront"

  project_name    = var.project_name
  environment     = "dev"
  frontend_image  = var.frontend_image
  frontend_image_tag = var.frontend_image_tag
  backend_api_url = "https://${module.ecs.alb_dns_name}"
}
