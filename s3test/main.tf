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
  destroy_bucket         = var.destroy_bucket
  tags                  = merge({ "ResourceName" = var.s3_bucket_name }, local.tags)

}