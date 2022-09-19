terraform {
  backend "s3" {
    bucket         = "dojo-vcl-prod-tfstate"
    dynamodb_table = "dojo-vcl-prod-tflock"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
