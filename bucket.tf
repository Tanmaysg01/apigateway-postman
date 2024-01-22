resource "aws_s3_bucket" "bucket1" {
  bucket = "input-api-bucket"
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "out-input-api-bucket"
}
