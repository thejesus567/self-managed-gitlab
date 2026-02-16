locals {
  rds-sg-name     = "gitlab-rds-sec-group"
  db-subnet-group = "gitlab-subnet-rds-group"
  db-identifier   = "gitlab-db-ha"
  master-username = "gitlab"
  db-port         = 5432
  db-name         = "gitlabhq_${var.env}"
}

# RDS security group
resource "aws_security_group" "rds-sg" {
  name        = local.rds-sg-name
  description = "Security group for RDS database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = local.rds-sg-name
    Environment = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgresql-ingress" {
  security_group_id            = aws_security_group.rds-sg.id
  referenced_security_group_id = aws_security_group.lb-sg.id
  from_port                    = local.db-port
  to_port                      = local.db-port
  ip_protocol                  = "tcp"
}

# DB Subnet group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = local.db-subnet-group
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = local.db-subnet-group
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.db-identifier

  engine            = "postgres"
  engine_version    = "17"
  instance_class    = "db.t3.micro"
  multi_az          = var.db_multi_az
  allocated_storage = 5

  db_name  = local.db-name
  username = local.master-username
  port     = local.db-port

  #TODO: Check thing below
  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["sg-12345678"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = ["subnet-12345678", "subnet-87654321"]

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
