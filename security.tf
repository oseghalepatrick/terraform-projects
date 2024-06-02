resource "aws_vpc" "de_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "data-team-airflow-instance"
  }
}

# Create a public subnet in AZ a
resource "aws_subnet" "de_public_subnet_a" {
  vpc_id                  = aws_vpc.de_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "airflow-public-a"
  }
}

# Create a public subnet in AZ b
resource "aws_subnet" "de_public_subnet_b" {
  vpc_id                  = aws_vpc.de_vpc.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "airflow-public-b"
  }
}

resource "aws_internet_gateway" "de_internet_gateway" {
  vpc_id = aws_vpc.de_vpc.id

  tags = {
    Name = "airflow-igw"
  }
}

resource "aws_route_table" "de_public_rt" {
  vpc_id = aws_vpc.de_vpc.id

  tags = {
    Name = "airflow_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.de_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.de_internet_gateway.id
}

# Create a route table association for the public subnets
resource "aws_route_table_association" "de_public_assoc_a" {
  subnet_id      = aws_subnet.de_public_subnet_a.id
  route_table_id = aws_route_table.de_public_rt.id
}

resource "aws_route_table_association" "de_public_assoc_b" {
  subnet_id      = aws_subnet.de_public_subnet_b.id
  route_table_id = aws_route_table.de_public_rt.id
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS"

  vpc_id = aws_vpc.de_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_security_group" "de_sg" {
  name        = "airflow_sg"
  description = "airflow security group"
  vpc_id      = aws_vpc.de_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a subnet group for the RDS instance
resource "aws_db_subnet_group" "airflow_db_subnet" {
  name = "airflow-db-subnet"
  subnet_ids = [
    aws_subnet.de_public_subnet_a.id,
    aws_subnet.de_public_subnet_b.id
  ]
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name = "redshift-subnet-group"
  subnet_ids = [
    aws_subnet.de_public_subnet_a.id,
    aws_subnet.de_public_subnet_b.id
  ]
}

# resource "aws_security_group" "vpc_bound" {
#   name = "vpc bound traffic"
#   vpc_id = aws_vpc.de_vpc.id


#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.de_vpc.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_vpc_endpoint" "interface" {
#   for_each           = toset(var.vpc_endpoints)
#   vpc_id             = aws_vpc.de_vpc.id
#   service_name       = each.key
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = [aws_security_group.vpc_bound.id]
#   subnet_ids = [
#     aws_subnet.de_public_subnet_a.id,
#     aws_subnet.de_public_subnet_b.id
#   ]
#   private_dns_enabled = true
# }