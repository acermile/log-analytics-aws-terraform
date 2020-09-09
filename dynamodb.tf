resource "aws_dynamodb_table" "orders-dynamodb-table" {
  name             = "${var.environment}-AminidhiOrders"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  hash_key         = "CustomerID"
  range_key        = "OrderID"

  attribute {
    name = "CustomerID"
    type = "N"
  }
  attribute {
    name = "OrderID"
    type = "S"
  }


  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }


  tags = {
    Name        = "${var.environment}-AminidhiOrders"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags, ttl
    ]
  }
}
