locals {
  table_name = "${var.service}-${var.stage}"
}

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "${local.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}