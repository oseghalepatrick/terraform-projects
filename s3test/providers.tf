terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5"
    }
  }

  backend "s3" {
    key = "state/s3/project-terraform.tfstate"
  }

}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "patrick"
  region                   = var.aws_region
}