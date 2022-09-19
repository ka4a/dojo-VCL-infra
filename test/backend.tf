terraform {
  backend "s3" {
    bucket         = "dojo-vcl-test-tfstate"
    dynamodb_table = "dojo-vcl-test-tflock"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "ap-northeast-1"
  }
}
