resource "aws_iam_role" "wp_role" {
  name               = "${var.service}-${var.environment}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "wordpress" {
  name = "${var.service}-${var.environment}-instance-profile"
  path = "/"
  role = aws_iam_role.wp_role.name
}