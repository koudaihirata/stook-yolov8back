plugin "aws" {
  enabled = true
  region  = "ap-northeast-3"
}

rule "aws_instance_invalid_type" {
  enabled = true
}
