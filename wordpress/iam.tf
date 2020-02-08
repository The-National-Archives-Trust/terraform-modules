/*
resource "aws_iam_role" "wp_ecs_role" {
  name               = "wp-${var.environment}-${var.service}-ecs-role"
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

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  policy_arn    = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role          = aws_iam_role.wp_ecs_role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "wp-${var.environment}-${var.service}-ecs-instance-profile"
  path = "/"
  role = aws_iam_role.wp_ecs_role.name
}*/
