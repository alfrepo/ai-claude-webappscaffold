# WHY THIS FILE EXISTS: Terraform outputs for the dev environment.
# These values are used in CI/CD (e.g., to set environment variables for E2E tests).

output "backend_alb_url" {
  description = "ALB DNS name for the backend"
  value       = "https://${module.ecs.alb_dns_name}"
}

output "frontend_url" {
  description = "CloudFront URL for the frontend"
  value       = "https://${module.s3_cloudfront.cloudfront_domain}"
}

output "rds_endpoint" {
  description = "RDS instance endpoint (private — not publicly accessible)"
  value       = module.rds.endpoint
  sensitive   = true
}
