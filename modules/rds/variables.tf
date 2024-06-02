
variable "db_identifier" {
  default     = ""
  type        = string
  description = ""
}
variable "db_instance_class" {
  default     = ""
  type        = string
  description = ""
}
variable "db_allocated_storage" {
  default     = ""
  type        = string
  description = ""
}
variable "db_username" {
  default     = ""
  type        = string
  description = ""
}
variable "db_password" {
  default     = ""
  type        = string
  description = ""
}
variable "db_subnet_name" {
  default     = ""
  type        = string
  description = ""
}
variable "rds_security_group_ids" {
  default     = []
  type        = list(any)
  description = ""
}
variable "rds_tag" {
  default     = ""
  type        = string
  description = ""
}

# General 
variable "aws_region" {}