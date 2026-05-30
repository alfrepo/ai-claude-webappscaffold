variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "instance_class" { type = string; default = "db.t3.micro" }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password_arn" { type = string }
variable "multi_az" { type = bool; default = false }
variable "deletion_protection" { type = bool; default = false }
