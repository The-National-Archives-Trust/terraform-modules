
resource "aws_route53_record" "wordpress" {
  zone_id = var.route53_zone_id
  name    = var.route53_record_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.wordpress.public_ip]
}

resource "aws_instance" "wordpress" {
  ami           = var.ami_id
  key_name      = var.key_name
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_1
  iam_instance_profile = aws_iam_instance_profile.wordpress.name

  vpc_security_group_ids = [
    aws_security_group.wp_public_access.id
  ]

  associate_public_ip_address = true

  root_block_device = {
    "volume_type"           = "standard"
    "volume_size"           = 40
    "delete_on_termination" = false
  }

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = true
  }
}
