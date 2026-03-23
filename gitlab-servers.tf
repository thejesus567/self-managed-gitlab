
locals {
  gitlab-server-name-a = "Gitlab-A"
  gitlab-server-name-b = "Gitlab-B"
}
data "aws_ami" "gitlab-ami" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-098a7db23c0aae947"]
  }

}

//key pair
resource "aws_key_pair" "gitlab-key" {
  key_name   = "gitlab-key"
  public_key = file("~/.ssh/gitlab-key.pub")

  tags = {
    Name = "bastion-host-a"
  }

}



resource "aws_instance" "gitalb-server-a" {
  ami           = data.aws_ami.gitlab-ami.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[0]

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  key_name = aws_key_pair.gitlab-key.key_name

  tags = {
    Name = local.gitlab-server-name-a
  }
}

resource "aws_instance" "gitalb-server-b" {
  ami           = data.aws_ami.gitlab-ami.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[1]

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  key_name = aws_key_pair.gitlab-key.key_name

  tags = {
    Name = local.gitlab-server-name-b
  }
}


