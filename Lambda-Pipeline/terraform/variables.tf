variable "app_name" {
  description = "Application name"
  default = "app_name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  default = "app-name-lambda"
  type        = string
}
