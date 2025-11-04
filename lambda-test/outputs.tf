output "function_url" {
  value       = aws_lambda_function_url.app_url.function_url
  description = "Public URL to invoke the Lambda that calls Bedrock"
}

output "lambda_name" {
  value = aws_lambda_function.app.function_name
}
