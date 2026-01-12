terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket  = "terra-tf-buck-12"
    key     = "strapi/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
