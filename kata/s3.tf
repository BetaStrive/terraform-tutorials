resource "aws_s3_bucket" "bucket_for_file" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket_for_file.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.bucket_for_file.bucket}/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = "${aws_vpc_endpoint.s3_endpoint.id}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "file" {
  bucket = aws_s3_bucket.bucket_for_file.bucket
  key    = "index.html"
  source = "files/index.html"
}