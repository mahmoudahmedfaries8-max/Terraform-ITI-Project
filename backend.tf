terraform {
  backend "s3" {
    bucket = "fares-s3-bucket-2025"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

