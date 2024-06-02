# General 
aws_region = ""

########
# RDS #
#######
db_identifier        = "airflow-db"
db_instance_class    = "db.t2.micro"
db_allocated_storage = 20
db_username          = "airflow"
db_password          = "airflow123"
db_name              = "postgres"
rds_tag              = "Airflow-RDS"

############
# Redshift #
############
rs_cluster_identifier = "demo-cluster"
rs_database_name      = "database_cluster"
rs_master_username    = "rs_user"
rs_master_pass        = "Awsuser123"
rs_nodetype           = "dc2.large"
rs_cluster_type       = "single-node"
rs_tag                = "Redshift-cluster"


########
# EC2 #
#######
ec2_tag          = "airflow_instance"
instance_type    = "t2.micro"
root_volume_size = 10
iam_role_arn     = "EC2AccessProfile"
s3_bucket        = "terraform-airflow-bkt"

#######################
# Airflow credentials #
#######################

admin_username  = "admin"
admin_firstname = "Admin"
admin_lastname  = "User"
admin_email     = "admin@example.com"
admin_password  = "admin"