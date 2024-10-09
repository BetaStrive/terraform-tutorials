resource "aws_s3_bucket" "bucket_for_file" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "file" {
  bucket = aws_s3_bucket.bucket_for_file.bucket
  key    = "example.txt"
  source = "files/example.txt"
}