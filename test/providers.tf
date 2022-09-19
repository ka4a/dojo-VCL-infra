provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = "~> 1.1"

  required_providers {
    aws        = "~> 4.8"
    kubernetes = "~> 2.8"
    tls        = "~> 3.1"
    template   = "~> 2.2"
    helm       = "2.5.1"
  }
}
