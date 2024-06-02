locals {
  name = "${var.project}-${var.prefix}"
  tags = {
    project     = var.project
    environment = terraform.workspace
  }
}

module "aws_s3_bucket" {
  source                = "../modules/s3"
  aws_region            = var.aws_region
  s3_bucket_name        = var.s3_bucket_name
  enable_lifecycle_rule = var.enable_lifecycle_rule
  s3_versioning         = var.s3_versioning
  destroy_bucket        = var.destroy_bucket
  tags                  = merge({ "ResourceName" = var.s3_bucket_name }, local.tags)

}

module "aws_dynamodb" {
  source        = "../modules/dynamodb"
  aws_region    = var.aws_region
  db_table_name = var.db_table_name
  billing_mode  = var.billing_mode
  hash_key      = var.hash_key
  attr_name     = var.attr_name
  attr_type     = var.attr_type
  tags          = merge({ "ResourceName" = var.db_table_name }, local.tags)

}