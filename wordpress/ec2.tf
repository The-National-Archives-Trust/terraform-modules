# Public Load Balancer
resource "aws_lb" "public_lb" {
  name = "${var.service}-${var.environment}-elb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.wp_public_access.id]
  subnets = [
    var.public_subnet_1,
    var.public_subnet_2
  ]

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = true
  }
}

resource "aws_instance" "wp" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.wp_app_access.id]
  iam_instance_profile = aws_iam_instance_profile.wordpress.name
  subnet_id = var.private_subnet_1

  tags = {
    Name = "${var.service}-${var.environment}"
    Service = var.service
    Terraform = true
  }
}

resource "aws_lb_target_group_attachment" "public_asg_attachment" {
  target_group_arn = aws_lb_target_group.wp_lb_target.id
  target_id = aws_instance.wp.id
}

resource "aws_lb_target_group" "wp_lb_target" {
  name = "${var.service}-${var.environment}-lb-target"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    interval = 30
    path = "/"
    port = "traffic-port"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = true
  }
}

resource "aws_lb_listener" "public_http_lb_listener" {
  default_action {
    target_group_arn = aws_lb_target_group.wp_lb_target.arn
    type = "forward"
  }
  protocol = "HTTP"
  load_balancer_arn = aws_lb.public_lb.arn
  port = 80
}

resource "aws_lb_listener" "public_https_lb_listener" {
  default_action {
    target_group_arn = aws_lb_target_group.wp_lb_target.arn
    type = "forward"
  }
  protocol = "HTTPS"
  load_balancer_arn = aws_lb.public_lb.arn
  port = 443
  certificate_arn = var.public_lb_ssl_cert_arn
  ssl_policy = "ELBSecurityPolicy-2016-08"
}
