provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "creator-tools-scheduler-terraform"
    key    = "app/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "current" {}

data "aws_ecr_repository" "ecr_repository" {
  name = "${var.app_name}-lambda"
}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = data.aws_ecr_repository.ecr_repository.name
  ecr_image_tag       = "latest"
}

data "aws_ecr_image" "lambda_image" {
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Principal: {
          Service: "lambda.amazonaws.com"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}

# IAM Role Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.app_name}-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "s3:*",
          "scheduler:*",
          "ses:*",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "arn:aws:ecr:${var.region}:${local.account_id}:repository/${data.aws_ecr_repository.ecr_repository.name}"
      },
      {
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

# Lambda Function Deployment from ECR
resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  image_uri     = "${data.aws_ecr_repository.ecr_repository.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"
  memory_size   = 512
  timeout       = 60

  environment {
    variables = {
      LAMBDA_ARN                  = "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.lambda_function_name}"
    }
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}
