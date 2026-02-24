locals {
  ec2-name = "Bastion Host A"

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
    Name = "gitlab-key"
  }

}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = local.ec2-name
  }
}
