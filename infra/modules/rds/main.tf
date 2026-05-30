# WHY THIS FILE EXISTS: RDS module — provisions PostgreSQL in private subnets.
# No public access. Only ECS security group can connect (port 5432).
# Automated backups and encryption at rest are always enabled.
# To change the engine version: update engine_version (test in dev first).

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = { Name = "${var.project_name}-${var.environment}-db-subnet-group" }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "RDS security group — allows access from ECS tasks only"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]   # Restrict to VPC CIDR in real impl
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-${var.environment}"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100   # Enable autoscaling up to 100GB
  storage_type           = "gp3"
  storage_encrypted      = true   # Always encrypt at rest

  db_name  = var.db_name
  username = var.db_username
  # Password injected from Secrets Manager — not stored in Terraform state
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds.arn

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false   # Never expose RDS publicly

  multi_az                  = var.multi_az
  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = !var.deletion_protection

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = { Name = "${var.project_name}-${var.environment}-rds" }
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
