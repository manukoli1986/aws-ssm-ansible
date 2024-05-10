

resource "aws_s3_bucket" "my_bucket" {
  bucket = "ssm-bucket-testing-1234" # Bucket names must be unique
  tags = {
    Name        = "My S3 Bucket"
    Environment = "Test"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "playbook.yml"
  source = "./playbook.yml"
  etag   = "${filemd5("${path.module}/playbook.yml")}"
}


# resource "null_resource" "upload_file" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   provisioner "local-exec" {
#     command = "aws s3 cp ./playbook.yml s3://${aws_s3_bucket.my_bucket.bucket}/playbook.yml --profile=mayank"
#   }
#   depends_on = [
#     aws_s3_bucket.my_bucket
#   ]
# }


