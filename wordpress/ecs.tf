resource "aws_ecs_cluster" "ecs" {
  name = "wp-${var.environment}-${var.service}-cluster"

  tags = {
    Service = var.service
    Environment = var.environment
    Terraform = "true"
  }
}

resource "aws_ecs_service" "ecs" {
  name = "wp-${var.environment}-${var.service}-ecs"
  cluster = aws_ecs_cluster.ecs.id
  desired_count = var.asg_desired_capacity
  task_definition = aws_ecs_task_definition.ecs.family
}

resource "aws_ecs_task_definition" "ecs" {
  family = "wp-${var.environment}-${var.service}"
  container_definitions = data.template_file.wordpress_task.rendered
  volume {
    name = "nfs-storage"
    host_path = "/mnt/wordpress"
  }
}

data "template_file" "wordpress_task" {
  template = file("${path.module}/templates/wordpress_task.json")
  vars = {
    repository_url = var.ecr_url
    image_tag = var.image_tag
    wp_db_user = var.wp_db_username
    wp_db_password = var.wp_db_password
    wp_db_name = var.wp_db_name
    wp_db_host = var.wp_db_host
    wp_domain = var.wp_domain
    wp_site_name = var.service
  }
}