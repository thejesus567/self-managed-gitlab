
/*-----VPC-----*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gitlab-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  manage_default_security_group = false
  map_public_ip_on_launch = true
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

/*-----Security groups-----*/
resource "aws_security_group" "gitlab-server-sg" {
  name        = "gitlab-server-sg"
  description = "security group for gitlab server"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "gitlab-server-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh-ingress-rule" {
  security_group_id = aws_security_group.gitlab-server-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "http-ingress-rule" {
  security_group_id = aws_security_group.gitlab-server-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "https-ingress-rule" {
  security_group_id = aws_security_group.gitlab-server-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.gitlab-server-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
/*-----EC2-----*/

//key pair
resource "aws_key_pair" "gitlab-key" {
  key_name   = "gitlab-key"
  public_key = file("~/.ssh/gitlab-key.pub")
  tags = {
    Name = "gitlab-key"
  }

}

//ami
data "aws_ami" "gitlab-ami" {
  most_recent = true
  owners      = ["782774275127"]

  filter {
    name   = "name"
    values = ["GitLab CE 16.11.2 (ARM64)"]
  }
} 

//server
resource "aws_instance" "gitlab-server" {
  ami                         = data.aws_ami.gitlab-ami.id
  instance_type               = "t4g.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.gitlab-server-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.gitlab-key.key_name


  tags = {
    Name = "gitlab-server"
  }
}
