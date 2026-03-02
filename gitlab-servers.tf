
locals {
  gitlab-server-name = "Gitlab"
}
data "aws_ami" "gitlab-ami" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-0a49af6bf7cba34c5"]
  }

}

resource "aws_instance" "gitalb-server-a" {
  ami           = data.aws_ami.gitlab-ami.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[0]

  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  tags = {
    Name = local.gitlab-server-name
  }
}


