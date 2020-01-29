variable "service" {}

resource "aws_ecr_repository" "ecr" {
  name = "wp_${var.service}_tna_trust"
}