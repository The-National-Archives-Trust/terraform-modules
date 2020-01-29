resource "aws_db_instance" "wp_db_master" {
  name                    = "wp${var.service}master"
  identifier_prefix       = "wp-${var.service}-ma-"
  allocated_storage       = 5
  storage_type            = "gp2"
  engine                  = "mariadb"
  license_model           = "general-public-license"
  instance_class          = var.wp_db_instance
  username                = var.wp_db_username
  password                = var.wp_db_password
  apply_immediately       = var.wp_db_apply_immediately
  db_subnet_group_name    = var.db_subnet_group
  multi_az                = var.wp_db_multi_az
  vpc_security_group_ids  = [
    aws_security_group.wp_db_access.id]
  parameter_group_name    = aws_db_parameter_group.wp_db_parameter_group.name
  allow_major_version_upgrade = true
  final_snapshot_identifier = "wp-${var.environment}-${var.service}-final-db-snapshot"
  backup_window           = var.wp_db_backup
  backup_retention_period = 14

  tags = {
    Name = "wp-${var.service}-db-master"
    Terraform = "True"
    Service = var.service
    Environment = var.environment
  }
}

resource "aws_db_instance" "wp_db_rr" {
  name                    = "wp${var.service}master"
  identifier_prefix       = "wp-${var.service}-rr-"
  allocated_storage       = 5
  storage_type            = "gp2"
  engine                  = "mariadb"
  license_model           = "general-public-license"
  instance_class          = var.wp_db_instance
  username                = var.wp_db_username
  password                = var.wp_db_password
  apply_immediately       = var.wp_db_apply_immediately
  replicate_source_db     = aws_db_instance.wp_db_master.identifier
  backup_window           = var.wp_db_backup
  backup_retention_period = 1
  skip_final_snapshot = true

  tags = {
    Name = "wp-${var.service}-db-rr"
    Terraform = "True"
    Service = var.service
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "wp_db_parameter_group" {
  name = "wp-${var.environment}-${var.service}-db-mariadb"
  family = var.wp_db_group_family

  parameter {
    name = "log_bin_trust_function_creators"
    value = "1"
  }
}