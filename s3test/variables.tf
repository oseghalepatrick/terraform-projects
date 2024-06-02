# Tags
variable "project" {}
variable "prefix" {}
variable "suffix" {}

# General 
variable "aws_region" {}

# S3 Backend
variable "s3_bucket_name" {}
variable "s3_versioning" {}
variable "enable_lifecycle_rule" {}
variable "destroy_bucket" {}