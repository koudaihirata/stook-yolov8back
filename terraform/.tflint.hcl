config {
    module = true
}

plugin "aws" {
  enabled = true
  region  = "ap-northeast-3"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

plugin "terraform" {
  enabled = true
}

rule terraform_documented_outputs {
  enabled = false
}

rule terraform_documented_variables {
  enabled = false
}

rule terraform_naming_convention {
  enabled = false
}

rule terraform_required_version {
  enabled = false
}

rule terraform_required_providers {
  enabled = false
}
