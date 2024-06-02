variable "rs_cluster_identifier" {}

variable "rs_database_name" {}

variable "rs_master_username" {}

variable "rs_master_pass" {}

variable "rs_nodetype" {}

variable "rs_cluster_type" {}

variable "rs_tag" {}

variable "redshift_subnet_group_id" {}

variable "redshift_iam_role_arn" {
  type        = list(any)
  default     = []
  description = ""
}

variable "aws_region" {}

