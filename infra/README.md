# Infrastructure (Terraform)

WHY THIS DIRECTORY EXISTS: All AWS infrastructure is defined here as Terraform code.
No click-ops. Every resource must be in Terraform. See ADR-0001 for the cloud strategy.

## Structure

```
infra/
├── modules/              # Reusable Terraform modules
│   ├── vpc/              # VPC, subnets, NAT gateway, internet gateway
│   ├── ecs/              # ECS cluster, task definitions, services, ALB
│   ├── rds/              # RDS PostgreSQL (private subnet)
│   ├── s3-cloudfront/    # S3 bucket + CloudFront distribution for frontend
│   └── secrets-manager/  # AWS Secrets Manager secrets
└── environments/
    ├── dev/              # Development environment
    └── prod/             # Production environment
```

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform 1.7+ installed
3. S3 bucket for Terraform state (create once, out-of-band)
4. DynamoDB table for state locking (create once, out-of-band)

## Quickstart

```bash
# Initialize (once per environment)
cd infra/environments/dev
terraform init -backend-config="bucket=your-tf-state-bucket"

# Preview changes
terraform plan

# Apply changes
terraform apply
```

## Adding a New Module

1. Create the module directory under `modules/`
2. Define `main.tf`, `variables.tf`, `outputs.tf`
3. Reference it in the environment `main.tf` via `module "name" { source = "../../modules/name" }`
4. Write an ADR if the module introduces a new AWS service
