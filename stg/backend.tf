terraform {
  backend "s3" {
    bucket         = "dojo-vcl-stg-tfstate"
    dynamodb_table = "dojo-vcl-stg-tflock"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
