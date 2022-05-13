
resource "aws_s3_bucket" "lock_state" {
  bucket = "test-bucket-${terraform.workspace}"
  acl    = "private"
  //lifecycle {
  //  prevent_destroy = true
  //}
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "lock_state_db" {
  hash_key = "LockID"
  name = "test-db-${terraform.workspace}"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
