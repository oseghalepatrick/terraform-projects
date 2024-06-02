output "dev_ip" {
  value = aws_instance.this.public_ip
}

output "id" {
  value     = aws_instance.this.id
  sensitive = true
}

# output "db_endpoint" {
#   value = aws_db_instance.airflow_db.endpoint
# }

# output "iam_instance_profile" {
#   value = aws_iam_instance_profile.s3_ssm_access_profile.name
# }