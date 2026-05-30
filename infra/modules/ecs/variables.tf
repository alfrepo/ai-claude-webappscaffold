variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "backend_image" { type = string }
variable "backend_image_tag" { type = string }
variable "db_url" { type = string }
variable "db_secret_arn" { type = string }
variable "frontend_origin" { type = string }
variable "task_cpu" { type = number; default = 512 }
variable "task_memory" { type = number; default = 1024 }
variable "desired_count" { type = number; default = 1 }
