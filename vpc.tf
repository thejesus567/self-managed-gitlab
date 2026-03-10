locals {
  igw_name = "gitlab-gateway"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gitlab-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.3.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  map_public_ip_on_launch = true

  # Uncomment the line below if you require dedicated hardware.
  # instance_tenancy = "dedicated"

  tags = {
    Terraform   = "true"
    Environment = var.env
  }

  # IGW tag overrides
  igw_tags = {
    Name = local.igw_name
  }
}
