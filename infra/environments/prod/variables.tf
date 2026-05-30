# WHY THIS FILE EXISTS: Input variables for the production environment.

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "webapp"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "db_name" {
  type    = string
  default = "webapp"
}

variable "db_username" {
  type    = string
  default = "webapp"
}

variable "backend_image" {
  type = string
}

variable "backend_image_tag" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "frontend_image_tag" {
  type = string
}
