# Public Load Balancer
resource "aws_lb" "public_lb" {
  name_prefix = "wp${var.service}-"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.wp_public_access.id
  ]
  subnets = [
    var.public_subnet_1,
    var.public_subnet_2
  ]

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = "true"
  }
}

# WordPress autoscaling group and launch config
resource "aws_launch_configuration" "wp_launch_config" {
  name_prefix = "wp${var.service}-"
  image_id = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  security_groups = [aws_security_group.wp_app_access.id]
  user_data = data.template_file.ec2_userdata.rendered
  key_name = var.key_name

  lifecycle { create_before_destroy = true }
}

data "template_file" "ec2_userdata" {
  template = file("${path.module}/templates/userdata.sh")
  vars = {
    ecs_cluster = aws_ecs_cluster.ecs.name
    ecr_url   = var.ecr_url
    image_tag = var.image_tag
  }
}

resource "aws_autoscaling_group" "wp" {
  name = "wp-${var.environment}-${var.service}-asg"
  launch_configuration = aws_launch_configuration.wp_launch_config.name
  vpc_zone_identifier = [
    var.private_subnet_1,
    var.private_subnet_2
  ]
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  health_check_grace_period = 300
  health_check_type = "EC2"
  tags = list(
      map("key", "Name", "value", "wp-${var.environment}-${var.service}", "propagate_at_launch", true),
      map("key", "Service", "value", "wordpress", "propagate_at_launch", true),
      map("key", "Terraform", "value", "true", "propagate_at_launch", true)
    )
}

resource "aws_lb_target_group" "wp_lb_target" {
  name = "wp-${var.environment}-${var.service}-lbtarget"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    interval = 30
    path = "/wp-content/healthcheck.html"
    port = "traffic-port"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = "true"
  }
}

resource "aws_autoscaling_attachment" "public_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wp.id
  alb_target_group_arn = aws_lb_target_group.wp_lb_target.arn
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
  certificate_arn = var.certificate_arn
  ssl_policy = "ELBSecurityPolicy-2016-08"
}