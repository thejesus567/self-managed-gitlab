## NLB Security group 

resource "aws_security_group" "lb-sg" {
  name        = "gitlab-loadbalancer-sec-group"
  description = "Security group for Network Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = "0.0.0.0/0" #TODO: Add a single trusted IP address, or an IP address range in CIDR notation.
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

module "nlb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "gitlab-loadbalancer"
  load_balancer_type = "network"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  # enforce_security_group_inbound_rules_on_private_link_traffic = "on"

  security_groups = [aws_security_group.lb-sg.id]

  tags = {
    Environment = var.env
  }
}

########## Target groups ##########
#
resource "aws_lb_target_group" "http-target" {
  name     = "gitlab-loadbalancer-http-target"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group" "https-target" {
  name     = "gitlab-loadbalancer-http-target"
  port     = 443
  protocol = "TLS"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group" "ssh-target" {
  name     = "gitlab-loadbalancer-ssh-target"
  port     = 22
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

###################################
