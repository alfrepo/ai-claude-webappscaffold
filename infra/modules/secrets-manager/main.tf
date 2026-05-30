# WHY THIS FILE EXISTS: Secrets Manager module — creates secret placeholders.
# Actual secret values are set out-of-band (CLI or console) — never in Terraform.
# ECS task execution role reads secrets at task startup via the 'secrets' block.
# To add a new secret: add an aws_secretsmanager_secret resource here,
# then reference it in the ECS task definition.

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/${var.environment}/db-password"
  description             = "PostgreSQL password for the ${var.environment} environment"
  recovery_window_in_days = 7

  tags = { Name = "${var.project_name}-${var.environment}-db-password" }
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.project_name}/${var.environment}/jwt-secret"
  description             = "JWT signing secret for the ${var.environment} environment"
  recovery_window_in_days = 7

  tags = { Name = "${var.project_name}-${var.environment}-jwt-secret" }
}
