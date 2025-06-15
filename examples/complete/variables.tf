variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket" {
  description = "Name of the S3 bucket to store MaxMind databases"
  type        = string
  default     = "maxmind-geoip-updater-example-bucket"
}

variable "secret_id" {
  description = "Name of the AWS Secrets Manager secret"
  type        = string
  default     = "MaxMindCredentials"
}
