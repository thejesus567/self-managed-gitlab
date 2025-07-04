
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
    Name = "example"
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
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

//server
resource "aws_instance" "gitlab-server" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.gitlab-server-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.gitlab-key.key_name

  tags = {
    Name = "gitlab-server"
  }
}