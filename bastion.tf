locals {
  ec2-name        = "Bastion Host A"
  bastion-sg-name = "bastion-sec-group"

}

resource "aws_security_group" "bastion-sg" {
  name        = local.lb-sg-name
  description = "Security group for Bastion host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = local.bastion-sg-name
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_ssh" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0" #TODO: Add a single trusted IP address, or an IP address range in CIDR notation.
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0b6c6ebed2801a5cb"]
  }

}

# TODO: Check if aws provider approved PR below 
# in order to use ephemeral values for my key pair
# https://github.com/hashicorp/terraform-provider-aws/pull/44102

# RSA key of size 4096 bits
#ephemeral "tls_private_key" "rsa" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

//key pair
resource "aws_key_pair" "gitlab-key" {
  key_name   = "gitlab-key"
  public_key = file("~/.ssh/gitlab-key.pub")

  tags = {
    Name = "bastion-host-a"
  }

}

resource "aws_instance" "bastion-host-a" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id = module.vpc.public_subnets[0]

  #TODO: missing eni

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]


  key_name = aws_key_pair.gitlab-key.key_name
  tags = {
    Name = local.ec2-name
  }
}
