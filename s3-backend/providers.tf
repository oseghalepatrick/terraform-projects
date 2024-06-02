terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }

}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "patrick"
  region                   = var.aws_region
}