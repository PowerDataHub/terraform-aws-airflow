resource "aws_s3_bucket" "airflow-logs" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"

  tags = {
    Name = "${var.s3_bucket_name}"
  }
}
