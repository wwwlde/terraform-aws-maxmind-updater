output "lambda_function_name" {
  value = aws_lambda_function.maxmind_updater.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.maxmind_updater.arn
}
