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
