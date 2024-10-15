output "api_url" {
  description = "API GatewayのエンドポイントURL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "ecr_repository_url" {
  description = "ECRリポジトリURL"
  value       = aws_ecr_repository.this.repository_url
}
