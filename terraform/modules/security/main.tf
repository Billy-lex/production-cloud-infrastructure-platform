# -----------------------------------------------------------------------------
# Nginx Security Group (public subnet - internet facing)
# -----------------------------------------------------------------------------

resource "aws_security_group" "nginx" {
  name_prefix = "${var.project_name}-${var.environment}-nginx-"
  description = "Security group for Nginx reverse proxy"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-nginx-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "nginx_http" {
  security_group_id = aws_security_group.nginx.id
  description       = "Allow HTTP from internet"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "nginx_https" {
  security_group_id = aws_security_group.nginx.id
  description       = "Allow HTTPS from internet"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "nginx_ssh" {
  security_group_id = aws_security_group.nginx.id
  description       = "Allow SSH from trusted sources"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "nginx_all" {
  security_group_id = aws_security_group.nginx.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# Application Security Group (private subnet - internal only)
# -----------------------------------------------------------------------------

resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  description = "Security group for application server"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_nginx" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow traffic from Nginx SG"
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nginx.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow SSH from Nginx SG (bastion)"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nginx.id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# IAM Role for EC2 instances
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
