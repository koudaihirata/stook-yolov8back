provider "aws" {
  region = "ap-northeast-3"
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.app_name}-repo"
  image_tag_mutability = "MUTABLE"
  tags                 = var.tags
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = "${var.app_name}-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  image_uri     = "${aws_ecr_repository.this.repository_url}:latest"
  package_type  = "Image"
  tags          = var.tags
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.app_name}-api"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  tags        = var.tags
}

resource "aws_iam_policy" "ecr_push_policy" {
  name        = "${var.app_name}-ECRPushPolicy"
  description = "Policy to allow pushing Docker images to ECR"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}
