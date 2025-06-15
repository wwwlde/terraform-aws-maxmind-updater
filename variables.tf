variable "name_prefix" {
  type        = string
  description = "Prefix for Lambda and IAM resources"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket to store .mmdb files"
}

variable "s3_prefix" {
  type    = string
  default = "maxmind/"
}

variable "editions" {
  type        = string
  default     = "GeoLite2-City,GeoLite2-Country,GeoLite2-ASN"
  description = "Comma-separated list of MaxMind edition IDs"
}

variable "secret_id" {
  type        = string
  default     = "MaxMindCredentials"
  description = "Name of AWS Secrets Manager secret storing MaxMind credentials"
}

variable "enable_schedule" {
  type    = bool
  default = false
}

variable "schedule_expression" {
  type    = string
  default = "cron(0 3 ? * MON *)"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of private subnet IDs for Lambda to run in VPC"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for Lambda"
  default     = []
}
