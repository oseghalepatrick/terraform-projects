variable "ec2_tag" {
  type        = string
  default     = "airflow_instance"
  description = "description"
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  default     = "airflow"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  default     = "airflow123"
}

variable "db_name" {
  description = "The name of the database in the RDS instance"
  type        = string
  default     = "postgres"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.medium"
}

variable "root_volume_size" {
  description = "Root volume size"
  type        = string
  default     = 10
}

variable "host_os" {
  type    = string
  default = "mac"
}

variable "aws_subnet" {
  type        = string
  default     = ""
  description = "description"
}

variable "aws_security_group_ids" {
  type        = list(any)
  default     = []
  description = "description"
}

variable "aws_db_instance_endpoint" {
  type        = string
  default     = ""
  description = "description"
}


variable "aws_iam_instance_profile" {
  description = "ARN of the IAM role with permissions to access S3."
  type        = string
  default     = ""
}

variable "s3_bucket" {
  type        = string
  description = "The name of the S3 bucket containing the DAGs"
  default     = "terraform-airflow-bkt"
}

variable "s3_secret_bucket" {
  type        = string
  description = "The name of the S3 bucket containing the DAGs"
  default     = "secrets-bkt"
}

#######################
# Airflow credentials #
#######################

variable "admin_username" {
  description = "Username of the admin user"
  type        = string
  default     = "admin"
}

variable "admin_firstname" {
  description = "First name of the admin user"
  type        = string
  default     = "Admin"
}

variable "admin_lastname" {
  description = "Last name of the admin user"
  type        = string
  default     = "User"
}

variable "admin_email" {
  description = "Email address of the admin user"
  type        = string
  default     = "admin@example.com"
}

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
  default     = "admin"
}

# General 
variable "aws_region" {}