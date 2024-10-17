terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.29.0"
    }
  }
  backend "s3" {
    bucket = "stook-yolov8back-terraform"
    region = "ap-northeast-3"
    key    = "prod.tfstate"
  }
}

data "aws_caller_identity" "current" {}
