

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

variable "db_instance" {
  type        = string
  description = "DB instance type"
  default     = "db.t3.micro"
}

variable "db_size" {
  type        = number
  description = "DB instence size"
  default     = 25
}

variable "db_deletion_protection" {
  type        = bool
  description = "Protect DB from deletion"
  default     = false

}
