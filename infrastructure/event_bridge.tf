# event rules

resource "aws_cloudwatch_event_rule" "inspector2_scan" {
  name        = "${local.stack_name}-inspector2-scan"
  description = "Listen to Inspector2 Scan events"

  event_pattern = jsonencode({
    source: ["aws.inspector2"],
    detail-type = [
      "Inspector2 Scan"
    ]
  })
}

resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name        = "${local.stack_name}-ecr-image-scan"
  description = "Listen to ECR Image Scan events"

  event_pattern = jsonencode({
    source: ["aws.ecr"],
    detail-type = [
      "ECR Image Scan"
    ]
  })
}

# resource "aws_iam_role" "event_bridge_sqs_role" {
#   name = "event_bridge_sqs_role"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Service" : "scheduler.amazonaws.com"
#         },
#         "Action" : "sts:AssumeRole"
#       }
#     ]
#   })
# }

# topics

resource "aws_sns_topic" "aws_inspector2_scan_v1" {
  name = "${var.environment}-aws-inspector2-scan-v1"
}

resource "aws_sns_topic_policy" "aws_inspector2_scan_v1" {
  arn    = aws_sns_topic.aws_inspector2_scan_v1.arn
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.aws_inspector2_scan_v1.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.inspector2_scan.arn}"
        }
      }
    }
  ]
}
POLICY  
}

resource "aws_sns_topic" "aws_ecr_image_scan_v1" {
  name = "${var.environment}-aws-ecr-image-scan-v1"
}

resource "aws_sns_topic_policy" "aws_ecr_image_scan_v1" {
  arn    = aws_sns_topic.aws_ecr_image_scan_v1.arn
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.aws_ecr_image_scan_v1.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.ecr_image_scan.arn}"
        }
      }
    }
  ]
}
POLICY  
}

# subscriptions

resource "aws_cloudwatch_event_target" "aws_inspector2_scan_to_topic" {
  rule      = aws_cloudwatch_event_rule.inspector2_scan.id
  arn       = aws_sns_topic.aws_inspector2_scan_v1.arn
}

resource "aws_cloudwatch_event_target" "aws_ecr_image_scan_to_aws_ecr_image_scan_v1" {
  rule      = aws_cloudwatch_event_rule.ecr_image_scan.id
  arn       = aws_sns_topic.aws_ecr_image_scan_v1.arn
}

# resource "aws_sqs_queue" "ecr_enhanced_scan_complete_worker" {
#   name                      = "${aws_sns_topic.ecr_enhanced_scan_complete.name}-worker"
#   delay_seconds             = 0
#   max_message_size          = 2048
#   message_retention_seconds = 86400
#   receive_wait_time_seconds = 10
# }

# resource "aws_sns_topic_subscription" "topic-subscription" {
#   topic_arn = aws_sns_topic.ecr_enhanced_scan_complete.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.ecr_enhanced_scan_complete_worker.arn
# }




