resource "aws_sns_topic" "inspector_scan_updated_v1" {
  name = "${var.environment}-inspector-scan-updated-v1"
}

resource "aws_sns_topic" "ecr_scan_updated_v1" {
  name = "${var.environment}-ecr-scan-updated-v1"
}