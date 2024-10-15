variable "app_name" {
  description = "Application name"
  type        = string
  default     = "flask-app"
}

variable "tags" {
  description = "Commonly used tags"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "sample"
  }
}
