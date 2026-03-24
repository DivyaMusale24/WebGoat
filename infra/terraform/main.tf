# -------------------------------------------------------
# INTENTIONALLY MISCONFIGURED for demo/scanning purposes
# Checkov will flag: public S3 bucket + open security group
# -------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

# FINDING 1: S3 bucket with public read access
# Real-world impact: exposed customer data (Capital One breach)
resource "aws_s3_bucket" "demo" {
  bucket = "securepipeline-demo-bucket"
}

resource "aws_s3_bucket_acl" "demo_acl" {
  bucket = aws_s3_bucket.demo.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "demo_versioning" {
  bucket = aws_s3_bucket.demo.id
  versioning_configuration {
    status = "Disabled"
  }
}

# FINDING 2: Security group open to entire internet
# Real-world impact: any IP can reach any port
resource "aws_security_group" "demo_sg" {
  name        = "insecure-open-sg"
  description = "Demo insecure security group"

  ingress {
    description = "Open to world"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# FINDING 3: EC2 instance with no encryption
resource "aws_instance" "demo_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  root_block_device {
    encrypted = false
  }
}