variable "env" {
  type        = string
  description = "Enviroment"
  default     = "dev"
}

variable "db_multi_az" {
  type        = bool
  description = "Multi AZ deployment for RDS database"
  default     = false
}
