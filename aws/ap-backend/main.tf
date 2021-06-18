resource "aws_s3_bucket" "static_content" {
  bucket = "${var.name}-${var.region}-${var.host_zone}"
  acl    = var.s3_acl

  website {
      index_document = "index.html"
  }

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}