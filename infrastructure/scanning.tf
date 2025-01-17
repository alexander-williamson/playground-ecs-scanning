resource "aws_ecr_repository" "basic_image_scanning" {
  name                 = "${local.stack_name}-basic-image-scanning"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ecr_registry_scanning_configuration" "basic_image_scanning" {
#   scan_type = "BASIC"
#   rule {
#     scan_frequency = "SCAN_ON_PUSH"
#     repository_filter {
#       // regex https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_ScanningRepositoryFilter.html
#       filter      = aws_ecr_repository.basic_image_scanning.name 
#       filter_type = "WILDCARD"
#     }
#   }
# }

# resource "aws_ecr_registry_scanning_configuration" "enhanced_image_scanning" {
#   scan_type = "ENHANCED"
#   rule {
#     scan_frequency = "SCAN_ON_PUSH"
#     repository_filter {
#       // regex https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_ScanningRepositoryFilter.html
#       filter      = aws_ecr_repository.basic_image_scanning.name 
#       filter_type = "WILDCARD"
#     }
#   }
#   rule {
#     scan_frequency = "CONTINUOUS_SCAN"
#     repository_filter {
#       // regex https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_ScanningRepositoryFilter.html
#       filter      = aws_ecr_repository.basic_image_scanning.name
#       filter_type = "WILDCARD"
#     }
#   }
# }