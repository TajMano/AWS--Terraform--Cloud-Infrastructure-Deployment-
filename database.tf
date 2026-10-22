resource "aws_dynamodb_table" "demo" {
  name         = "${var.project_name}-records"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Email"
  range_key    = "RecordNumber"

  attribute {
    name = "Email"
    type = "S"
  }

  attribute {
    name = "RecordNumber"
    type = "S"
  }
}

# Entirely fictional sample. Disabled by default to keep the base deployment minimal.
resource "aws_dynamodb_table_item" "sample" {
  count      = var.create_sample_item ? 1 : 0
  table_name = aws_dynamodb_table.demo.name
  hash_key   = aws_dynamodb_table.demo.hash_key
  range_key  = aws_dynamodb_table.demo.range_key

  item = jsonencode({
    Email          = { S = "portfolio@example.invalid" }
    RecordNumber   = { S = "demo-0001" }
    CustomerName   = { S = "Sample Customer" }
    Status         = { N = "0" }
    RawS3URL       = { S = "" }
    FinishedS3URL  = { S = "" }
  })
}
