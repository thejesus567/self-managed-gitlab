locals {
  rds-sg-name = "gitlab-rds-sec-group"
}

# RDS security group
resource "aws_security_group" "rds-sg" {
  name        = local.rds-sg-name
  description = "Security group for RDS database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgresql-ingress" {
  security_group_id            = aws_security_group.rds-sg.id
  referenced_security_group_id = aws_security_group.lb-sg.id
  ip_protocol                  = -1
}


