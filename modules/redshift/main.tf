provider "aws" {
  region  = var.aws_region
  profile = "patrick"
}

resource "aws_redshift_cluster" "default" {
  cluster_identifier        = var.rs_cluster_identifier
  database_name             = var.rs_database_name
  master_username           = var.rs_master_username
  master_password           = var.rs_master_pass
  node_type                 = var.rs_nodetype
  cluster_type              = var.rs_cluster_type
  number_of_nodes           = var.rs_number_of_nodes
  cluster_subnet_group_name = var.redshift_subnet_group_id
  skip_final_snapshot       = true
  iam_roles                 = var.redshift_iam_role_arn

  tags = {
    Name = var.rs_tag
  }
}
