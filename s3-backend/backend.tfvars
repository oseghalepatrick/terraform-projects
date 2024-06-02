# Common
project = "projects"
prefix  = "tf-backend"

# General 
aws_region = ""
suffix     = "01"

# S3
s3_bucket_name        = "projects-tf-states"
s3_versioning         = "Enabled"
enable_lifecycle_rule = false
destroy_bucket        = true

# dynamodb
db_table_name = "projects-tf-locks"
billing_mode  = "PAY_PER_REQUEST"
hash_key      = "LockID"
attr_name     = "LockID"
attr_type     = "S"