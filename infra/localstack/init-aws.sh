#!/bin/bash
# WHY THIS FILE EXISTS: Initializes LocalStack with the AWS resources needed for local dev.
# Runs automatically when the LocalStack container starts (mounted as an init script).
# To add a new AWS resource for local dev: add the awslocal command below.
# IMPORTANT: awslocal is the LocalStack CLI wrapper around aws CLI.

set -e
echo "Initializing LocalStack AWS resources..."

# Create S3 bucket for frontend assets
awslocal s3 mb s3://webapp-local-frontend

# Create SQS queues
awslocal sqs create-queue --queue-name webapp-local-queue

# Create Secrets Manager secrets (with dummy values for local dev)
awslocal secretsmanager create-secret \
  --name "webapp/local/db-password" \
  --secret-string "webapp_dev"   # CHANGE_FOR_PRODUCTION

awslocal secretsmanager create-secret \
  --name "webapp/local/jwt-secret" \
  --secret-string "local-dev-jwt-secret-CHANGE_FOR_PRODUCTION"

echo "LocalStack initialization complete."
