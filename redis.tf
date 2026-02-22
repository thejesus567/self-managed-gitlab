locals {
  redis-sg-name = "gitlab-redis-sec-group"
  redis-port    = 6379
}
# RDS security group
resource "aws_security_group" "redis-sg" {
  name        = local.redis-sg-name
  description = "Security group for Redis database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = local.redis-sg-name
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis-ingress" {
  security_group_id            = aws_security_group.redis-sg.id
  referenced_security_group_id = aws_security_group.lb-sg.id
  from_port                    = local.redis-port
  to_port                      = local.redis-port
  ip_protocol                  = "tcp"
}


