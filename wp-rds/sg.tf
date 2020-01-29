# WordPress Security Group database access
resource "aws_security_group" "wp_db_access" {
  name = "wp-${var.environment}-${var.service}-db-access"
  description = "DB security group"
  vpc_id = var.vpc_id

  tags = {
    Name = "wp_${var.environment}_${var.service}_db_access"
    Environment = var.environment
    Terraform = "True"
    Service = var.service
  }
}

resource "aws_security_group_rule" "wp_db_egress" {
  security_group_id = aws_security_group.wp_db_access.id
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}