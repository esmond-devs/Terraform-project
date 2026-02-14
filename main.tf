# 1. Define the Cloud Provider
provider "aws" {
  region = "us-east-1"
}

# 2. Enable Amazon GuardDuty (Intelligent Threat Detection)
resource "aws_guardduty_detector" "primary" {
  enable = true
}

# 3. Create a KMS Key for encrypting CloudWatch Logs
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for CloudWatch log group encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# 4. Create a CloudWatch Log Group for Security Logs (encrypted)
resource "aws_cloudwatch_log_group" "security_logs" {
  name              = "infrastructure-security-logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
}

# 5. Example: A Security Group with restricted traffic
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound and restricted outbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Only allow internal traffic
  }

  egress {
    description = "HTTPS outbound to internal network only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Restricted to internal network
  }
}
