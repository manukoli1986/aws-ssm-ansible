

resource "aws_s3_bucket" "my_bucket" {
  bucket = "ssm-bucket-testing-1234"  # Bucket names must be unique
  tags = {
    Name        = "My S3 Bucket"
    Environment = "Test"
  }
}


resource "null_resource" "upload_file" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ./playbook.yml s3://${aws_s3_bucket.my_bucket.bucket}/playbook.yml --profile=mayank"
  }
  depends_on = [
    aws_s3_bucket.my_bucket
  ]
}





resource "aws_ssm_document" "foo" {
  name          = "test_document"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Check ip configuration of a Linux instance.",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["ifconfig"]
          }
        ]
      }
    }
  }
DOC
}

## aws ssm send-command --document-name "AWS-ApplyAnsiblePlaybooks" --document-version "1" --targets '[{"Key":"InstanceIds","Values":["i-004071201395542c3"]}]' --parameters '{"SourceType":["S3"],"SourceInfo":["{\n \"path\":\"https://s3.amazonaws.com/ssm-bucket-testing-1234/playbook.yml\"\n}"],"InstallDependencies":["True"],"PlaybookFile":["hello-world-playbook.yml"],"ExtraVariables":["SSM=True"],"Check":["False"],"Verbose":["-v"],"TimeoutSeconds":["3600"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "ssm-bucket-testing-1234" --output-s3-key-prefix "otput" --region ap-south-1 --profile=mayank