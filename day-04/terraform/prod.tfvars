aws_region      = "ap-south-1"
environment     = "prod"

vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones = ["ap-south-1a", "ap-south-1b"]

instance_type   = "t3.micro"
key_pair_name   = "dev-key"
allowed_ssh_cidr = "0.0.0.0/32"

db_name         = "strapi"
db_username     = "strapi"
db_password     = "StrapiDB123!"
db_instance_class = "db.t3.micro"

ecr_image_uri = "730335385079.dkr.ecr.ap-south-1.amazonaws.com/strapi-app:94176834"

