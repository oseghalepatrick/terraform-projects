# Create an IAM role for the EC2 instance to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2-iam-role"

  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": [
              "ec2.amazonaws.com",
              "redshift.amazonaws.com",
              "redshift-serverless.amazonaws.com",
              "scheduler.redshift.amazonaws.com"
            ]
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    EOF
}

resource "aws_iam_instance_profile" "ec2_access_profile" {
  name = var.iam_role_arn
  role = aws_iam_role.ec2_role.name
}

# Attach the required policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "redshift_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy_attachment" "emr_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2"
}

# Allow the Redshift scheduler to use this role (PassRole + scheduled actions)
resource "aws_iam_role_policy" "redshift_scheduler_permissions" {
  name = "AllowRedshiftSchedulerPassRole"
  role = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPassThisRoleToRedshift",
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = aws_iam_role.ec2_role.arn
      },
      {
        Sid    = "AllowRedshiftScheduledActions",
        Effect = "Allow",
        Action = [
          "redshift:CreateScheduledAction",
          "redshift:DeleteScheduledAction",
          "redshift:DescribeScheduledActions",
          "redshift:PauseCluster",
          "redshift:ResumeCluster",
          "redshift:ResizeCluster"
        ],
        Resource = "*"
      }
    ]
  })
}
