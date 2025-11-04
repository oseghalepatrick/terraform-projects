provider "aws" {
  region  = var.aws_region
  profile = "patrick"
}

resource "aws_key_pair" "this" {
  key_name   = "airflow-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "this" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ami.id
  key_name               = aws_key_pair.this.id
  vpc_security_group_ids = var.aws_security_group_ids
  subnet_id              = var.aws_subnet
  iam_instance_profile   = var.aws_iam_instance_profile
  user_data = templatefile("modules/ec2/userdata.tpl", {
    db_endpoint     = var.aws_db_instance_endpoint
    db_username     = var.db_username
    db_password     = var.db_password
    db_name         = var.db_name
    admin_username  = var.admin_username
    admin_firstname = var.admin_firstname
    admin_lastname  = var.admin_lastname
    admin_email     = var.admin_email
    admin_password  = var.admin_password
    s3_bucket       = var.s3_bucket
  })

  depends_on = [aws_instance.this]

  root_block_device {
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = var.ec2_tag
  }

  provisioner "local-exec" {
    command = templatefile("modules/ec2/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/id_rsa"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}