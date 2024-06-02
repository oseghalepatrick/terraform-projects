provider "aws" {
  region  = var.aws_region
  profile = "patrick"
}

resource "aws_dynamodb_table" "this" {
  name           = var.db_table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  stream_enabled = false
  table_class    = "STANDARD_INFREQUENT_ACCESS"

  attribute {
    name = var.attr_name
    type = var.attr_type
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge({ "ResourceName" = var.db_table_name }, var.tags)
}