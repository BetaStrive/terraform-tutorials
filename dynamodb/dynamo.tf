resource "aws_dynamodb_table" "example" {
  name           = "example-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"
  range_key      = "Timestamp"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "N"
  }

  global_secondary_index {
    name               = "GSI-Example"
    hash_key           = "Timestamp"
    projection_type    = "ALL"

    read_capacity  = 5
    write_capacity = 5
  }

  tags = {
    Environment = "development"
    Team        = "backend"
  }
}