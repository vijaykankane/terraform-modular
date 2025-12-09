resource "aws_dynamodb_table" "state" {
  name         = "${var.environment}-app-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}