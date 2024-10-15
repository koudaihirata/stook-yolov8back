output "api_url" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "ecr_registry" {
  description = "Amazon ECR registry URL"
  value       = aws_ecr_repository.this.repository_url
}
