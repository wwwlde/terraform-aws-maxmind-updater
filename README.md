# 🚀 terraform-aws-maxmind-updater

This Terraform module deploys an AWS Lambda function that automatically updates MaxMind **GeoLite2** databases to an S3 bucket — only when changes are detected via official `.sha256` checksums.

---

## ✅ Features

* Supports multiple MaxMind GeoLite2 databases:

  * `GeoLite2-City`
  * `GeoLite2-Country`
  * `GeoLite2-ASN`
* Automatically downloads and unpacks `.mmdb` files only if the hash has changed
* Stores downloaded databases in S3
* Maintains `hashes.json` in S3 for change tracking (with `sha256` and `updated_at` timestamps)
* Optional scheduled updates via EventBridge (cron)
* **Secure secret management using AWS Secrets Manager**
* Optional VPC configuration support

---

## 🔐 Secure Credentials

This module **does not expose MaxMind credentials in the Lambda environment**.

Instead:

* Store your credentials in [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
* Lambda reads them securely at runtime

### Example Secret (`MaxMindCredentials`):

```json
{
  "ACCOUNT_ID": "your-maxmind-account-id",
  "LICENSE_KEY": "your-maxmind-license-key"
}
```

---

## 📦 Usage

### 1. Create the MaxMind secret

```bash
aws secretsmanager create-secret \
  --name MaxMindCredentials \
  --secret-string '{"ACCOUNT_ID":"your-id","LICENSE_KEY":"your-key"}'
```

### 2. Package your Lambda function

```bash
./build_lambda.sh
```

This creates a `lambda_function.zip` in the root of the module.

### 3. Use the module in Terraform

```hcl
module "maxmind_updater" {
  source               = "./terraform-maxmind-updater"
  name_prefix          = "maxmind"
  s3_bucket            = "your-s3-bucket-name"

  editions             = "GeoLite2-City,GeoLite2-Country,GeoLite2-ASN"
  s3_prefix            = "geoip/"
  secret_id            = "MaxMindCredentials"
  enable_schedule      = true
  schedule_expression  = "cron(0 3 ? * MON *)"

  subnet_ids           = ["subnet-...", "subnet-..."]
  security_group_ids   = ["sg-..."]
}
```

---

## ⚙️ Input Variables

| Name                  | Type           | Required | Description                                                   |
| --------------------- | -------------- | -------- | ------------------------------------------------------------- |
| `name_prefix`         | `string`       | Yes      | Prefix for naming Lambda and IAM resources                    |
| `region`              | `string`       | No       | AWS region (default: `eu-central-1`)                          |
| `s3_bucket`           | `string`       | Yes      | S3 bucket to store `.mmdb` files and `hashes.json`            |
| `s3_prefix`           | `string`       | No       | Prefix path in the S3 bucket (default: `maxmind/`)            |
| `editions`            | `string`       | No       | Comma-separated list of MaxMind databases                     |
| `secret_id`           | `string`       | No       | Name of Secrets Manager secret                                |
| `enable_schedule`     | `bool`         | No       | Whether to enable periodic updates                            |
| `schedule_expression` | `string`       | No       | EventBridge cron expression (default: every Monday 03:00 UTC) |
| `subnet_ids`          | `list(string)` | No       | Private subnet IDs for Lambda VPC networking                  |
| `security_group_ids`  | `list(string)` | No       | Security group IDs for Lambda in VPC                          |

---

## 📂 Outputs

| Name                   | Description                     |
| ---------------------- | ------------------------------- |
| `lambda_function_name` | The name of the deployed Lambda |
| `lambda_arn`           | ARN of the Lambda function      |

---

## 📁 Lambda Package Structure

Your `lambda_function.zip` must include:

```
lambda_function.zip
├── main.py
├── requests/            # Python dependency
└── ...
```

---

## 🛠 Packaging Script (`build_lambda.sh`)

```bash
#!/bin/bash
set -e

ZIP_NAME="lambda_function.zip"
ENTRY_FILE="main.py"
BUILD_DIR="lambda_build"

rm -rf $BUILD_DIR $ZIP_NAME
mkdir -p $BUILD_DIR

cp $ENTRY_FILE $BUILD_DIR/
pip install requests -t $BUILD_DIR/

cd $BUILD_DIR
zip -r9 ../$ZIP_NAME . > /dev/null
cd ..
rm -rf $BUILD_DIR

echo "✅ Built: $ZIP_NAME"
```

---

## 🛡 Required IAM Permissions

Lambda function requires the following actions:

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket",
    "secretsmanager:GetSecretValue",
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface"
  ],
  "Resource": "*"
}
```

Scope the resources as needed for least privilege.

---

## 🗓 Scheduling

If `enable_schedule = true`, the Lambda will be triggered automatically on schedule.

Example:

```
cron(0 3 ? * MON *)
```

This means every Monday at 03:00 UTC.

---

## 📄 License

MIT License — see `LICENSE` file.
