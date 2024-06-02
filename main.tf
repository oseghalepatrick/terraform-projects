# Create an RDS PostgreSQL instance
module "airflow_rds" {
  source                 = "./modules/rds"
  db_identifier          = var.db_identifier
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = var.db_allocated_storage
  db_username            = var.db_username
  db_password            = var.db_password
  db_subnet_name         = aws_db_subnet_group.airflow_db_subnet.name
  rds_security_group_ids = [aws_security_group.rds_security_group.id]
  rds_tag                = var.rds_tag
  aws_region             = var.aws_region
}

module "aws_redshift_cluster" {
  source                   = "./modules/redshift"
  rs_cluster_identifier    = var.rs_cluster_identifier
  rs_database_name         = var.rs_database_name
  rs_master_username       = var.rs_master_username
  rs_master_pass           = var.rs_master_pass
  rs_nodetype              = var.rs_nodetype
  rs_cluster_type          = var.rs_cluster_type
  redshift_subnet_group_id = aws_redshift_subnet_group.redshift_subnet_group.id
  redshift_iam_role_arn    = [aws_iam_role.ec2_role.arn]
  rs_tag                   = var.rs_tag
  aws_region               = var.aws_region
}

module "airflow_ec2_instance" {
  source                   = "./modules/ec2"
  instance_type            = var.instance_type
  aws_security_group_ids   = [aws_security_group.de_sg.id]
  aws_subnet               = aws_subnet.de_public_subnet_a.id
  aws_iam_instance_profile = aws_iam_instance_profile.ec2_access_profile.name
  aws_db_instance_endpoint = module.airflow_rds.db_endpoint
  db_username              = var.db_username
  db_password              = var.db_password
  db_name                  = var.db_name
  admin_username           = var.admin_username
  admin_firstname          = var.admin_firstname
  admin_lastname           = var.admin_lastname
  admin_email              = var.admin_email
  admin_password           = var.admin_password
  s3_bucket                = var.s3_bucket
  ec2_tag                  = var.ec2_tag
  root_volume_size         = var.root_volume_size
  aws_region               = var.aws_region
}


resource "null_resource" "remove_ssh_config_pattern" {
  triggers = {
    destroy = module.airflow_ec2_instance.id
  }

  provisioner "local-exec" {
    command     = "sed -i '' '/^Host airflow-ubuntu$/,/^  IdentityFile.*$/d' ~/.ssh/config"
    interpreter = ["bash", "-c"]
    when        = destroy
  }
}