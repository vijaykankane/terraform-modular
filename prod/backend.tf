terraform {
  backend "s3" {
    bucket = "dev-vijay-app-bucket"
    key    = "prod/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "dev-vijay-app-table"
  }
}
