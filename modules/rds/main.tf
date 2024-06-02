provider "aws" {
  region  = var.aws_region
  profile = "patrick"
}

# Create an RDS PostgreSQL instance
resource "aws_db_instance" "airflow_db" {
  identifier             = var.db_identifier
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  username               = var.db_username
  password               = var.db_password
  apply_immediately      = true
  skip_final_snapshot    = true
  db_subnet_group_name   = var.db_subnet_name
  vpc_security_group_ids = var.rds_security_group_ids
  port                   = "5432"

  tags = {
    Name = var.rds_tag
  }
}