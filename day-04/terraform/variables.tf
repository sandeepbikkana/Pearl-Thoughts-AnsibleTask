variable "aws_region" {}
variable "environment" {}

variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }

variable "instance_type" {}
variable "key_pair_name" {}
variable "allowed_ssh_cidr" {}

variable "ecr_image_uri" {}

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
