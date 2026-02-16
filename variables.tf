variable "env" {
  type        = string
  description = "Enviroment"
  default     = "dev"
}

variable "igw_tags" {
  description = "Extra / override tags for the Internet Gateway"
  type        = map(string)
  default = {
    Name = "gitlab-gateway"
  }
}

variable "db_multi_az" {
  type        = bool
  description = "Multi AZ deployment for RDS database"
  default     = false
}
