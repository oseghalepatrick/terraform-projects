output "redshift_cluster_id" {
  description = "The ID of the Redshift cluster"
  value       = aws_redshift_cluster.default.id
}

output "redshift_cluster_endpoint" {
  description = "The endpoint of the Redshift cluster"
  value       = aws_redshift_cluster.default.endpoint
}

output "redshift_cluster_master_username" {
  description = "The master username of the Redshift cluster"
  value       = aws_redshift_cluster.default.master_username
}
