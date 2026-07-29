# -----------------------------------------------------------------------------
# Data source: latest Ubuntu 22.04 LTS AMI
# -----------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  nginx_instance_type = var.nginx_instance_type != "" ? var.nginx_instance_type : var.instance_type
  app_instance_type   = var.app_instance_type != "" ? var.app_instance_type : var.instance_type
}

# -----------------------------------------------------------------------------
# Nginx Reverse Proxy (public subnet)
# -----------------------------------------------------------------------------

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.nginx_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.nginx_sg_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name != "" ? var.key_name : null

  user_data = base64encode(templatefile("${path.module}/templates/nginx_user_data.sh", {
    app_private_ip = var.app_fixed_private_ip
  }))

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-nginx"
    Role = "reverse-proxy"
  }
}

# -----------------------------------------------------------------------------
# Application Server (private subnet)
# -----------------------------------------------------------------------------

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.app_instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name != "" ? var.key_name : null
  private_ip             = var.app_fixed_private_ip

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app"
    Role = "application"
  }
}
