

output "bucket_name" { value = module.s3.s3_bucket_name }
output "dynamodb_table" { value = module.dynamodb.dynamodb_table_name }