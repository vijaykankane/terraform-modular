terraform {
  backend "s3" {
    bucket = "dev-vijay-app-bucket"
    key    = "uat/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "dev-vijay-app-table"
  }
}
