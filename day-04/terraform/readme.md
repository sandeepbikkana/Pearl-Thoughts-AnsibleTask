Strapi Deployment on AWS using Terraform
Overview

This project provisions AWS infrastructure using Terraform to deploy a Strapi application running inside a Docker container on a private EC2 instance, backed by PostgreSQL (RDS), and exposed securely via an Application Load Balancer (ALB).

The solution follows AWS best practices:

No public access to EC2 or database

Application exposed only through ALB

Infrastructure managed as code

Environment-specific configuration using tfvars


# Architecture
'''
User
  |
  | HTTP (80)
  v
Application Load Balancer (Public Subnets)
  |
  | HTTP (1337)
  v
Private EC2 (Docker + Strapi)
  |
  | TCP (5432)
  v
PostgreSQL (RDS - Private Subnets)
'''

---Key Components:

1)VPC with public and private subnets

2)NAT Gateway for outbound internet access from private EC2

3)Private EC2 instance running Strapi inside Docker

4)Amazon ECR hosting the Strapi Docker image

5)IAM Role allowing EC2 to pull images from ECR

6)Amazon RDS (PostgreSQL) for persistent storage

7)Application Load Balancer for secure external access

8)Bastion Host (optional) for SSH access to private EC2

9)Terraform Remote State stored in S3

---Repository Structure
.
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── dev.tfvars
├── prod.tfvars
└── README.md

---Prerequisites

1) Terraform >= 1.4

2) AWS CLI configured

3) ECR repository containing Strapi image

4) SSH key pair created in AWS

5)S3 bucket for Terraform remote state:

terra-tf-state

Terraform State Management

Terraform state is stored remotely in Amazon S3:

backend "s3" {
  bucket  = "terra-tf-state"
  key     = "strapi/terraform.tfstate"
  region  = "ap-south-1"
  encrypt = true
}

---Deployment Steps
1. Initialize Terraform
terraform init

2. Plan the Deployment
terraform plan -var-file=dev.tfvars

3. Apply the Infrastructure
terraform apply -var-file=dev.tfvars

4. Access the Application

After successful deployment, Terraform outputs the ALB DNS name:

alb_dns_name = <alb-dns>


Access Strapi via:

http://<alb-dns>

---EC2 User Data – Strapi Startup

--Strapi is started automatically on EC2 boot using user_data:

1) nstall Docker and AWS CLI

2) Authenticate to ECR using IAM role

3) Pull the Strapi image

4) Run the container with required environment variables

5) This ensures Strapi listens on all interfaces so the ALB can reach it.

6) Database Configuration

7) PostgreSQL is provisioned using Amazon RDS

8) Runs inside private subnets

9) Accessible only from the private EC2 instance via security groups

10) Connection details are passed to Strapi via environment variables

--- Security Best Practices Applied

EC2 and RDS are not publicly accessible

ALB is the only public entry point

Security groups use least privilege access

IAM role used for ECR authentication (no static credentials)


SSH access restricted to bastion host only (To connect to private Ec2)
