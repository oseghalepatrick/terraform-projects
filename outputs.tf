output "dev_ip" {
  value = module.airflow_ec2_instance.dev_ip
}

output "db_endpoint" {
  value = module.airflow_rds.db_endpoint
}

output "redshift_cluster_id" {
  value = module.aws_redshift_cluster.redshift_cluster_id
}

output "redshift_cluster_endpoint" {
  description = "The endpoint of the Redshift cluster"
  value       = module.aws_redshift_cluster.redshift_cluster_endpoint
}

output "redshift_cluster_master_username" {
  description = "The master username of the Redshift cluster"
  value       = module.aws_redshift_cluster.redshift_cluster_master_username
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_access_profile.name
}