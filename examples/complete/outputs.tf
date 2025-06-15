output "lambda_name" {
  value = module.maxmind_updater.lambda_function_name
}

output "lambda_arn" {
  value = module.maxmind_updater.lambda_arn
}

output "s3_bucket" {
  value = aws_s3_bucket.geoip.bucket
}

output "secret_name" {
  value = aws_secretsmanager_secret.maxmind.name
}
