terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2.0"
    }
  }
  required_version = "~> 1.14.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
