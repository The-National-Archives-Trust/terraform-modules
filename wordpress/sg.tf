
resource "aws_security_group" "wp_public_access" {
  name = "wp-${var.environment}-${var.service}-pub"
  description = "WordPress Security Group HTTP and HTTPS access"
  vpc_id = var.vpc_id

  tags = {
    Name = "wp-${var.environment}-${var.service}-pub"
    Environment = var.environment
    Terraform = "True"
    Service = var.service
  }
}

resource "aws_security_group_rule" "wp_lb_http_ingress" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.wp_public_access.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "wp_lb_http_egress" {
  security_group_id = aws_security_group.wp_public_access.id
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "wp_lb_https_ingress" {
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.wp_public_access.id
  to_port = 443
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "wp_ssh_ingress" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.wp_public_access.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
