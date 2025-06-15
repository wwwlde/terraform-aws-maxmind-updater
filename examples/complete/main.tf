provider "aws" {
  region = var.aws_region
}

# === S3 Bucket for storing .mmdb files ===
resource "aws_s3_bucket" "geoip" {
  bucket = var.s3_bucket
}

# === Secret with MaxMind credentials ===
resource "aws_secretsmanager_secret" "maxmind" {
  name = var.secret_id
}

resource "aws_secretsmanager_secret_version" "maxmind" {
  secret_id     = aws_secretsmanager_secret.maxmind.id
  secret_string = jsonencode({
    ACCOUNT_ID  = "your-maxmind-account-id"
    LICENSE_KEY = "your-maxmind-license-key"
  })
}

# === Optional IAM user (for uploading the secret) ===
resource "aws_iam_user" "maxmind_user" {
  name = "maxmind-secret-uploader"
}

resource "aws_iam_user_policy_attachment" "secrets" {
  user       = aws_iam_user.maxmind_user.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# === Call the MaxMind updater module ===
module "maxmind_updater" {
  source      = "../../"
  name_prefix = "maxmind"
  s3_bucket   = aws_s3_bucket.geoip.id

  editions        = "GeoLite2-City,GeoLite2-Country"
  secret_id       = aws_secretsmanager_secret.maxmind.name
  enable_schedule = true
  region          = var.aws_region
}
