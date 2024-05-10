
resource "aws_ssm_association" "ansible" {
  name = "AWS-ApplyAnsiblePlaybooks"
  association_name = "ansible"
  parameters = {
    SourceType = "S3"
    SourceInfo = <<EOJ
    {
        "path": "https://s3.amazonaws.com/${aws_s3_bucket.my_bucket.bucket}/playbook.yml"
    }
    EOJ
    PlaybookFile = "playbook.yml"
    InstallDependencies = "True"
    Verbose = "-v"
    }
  output_location {
    s3_bucket_name = aws_s3_bucket.my_bucket.id
  }

  targets {
    key    = "InstanceIds"
    values = [aws_instance.ssm_instance.id]
  }
}




# resource "aws_ssm_document" "foo" {
#   name          = "test_document"
#   document_type = "Command"

#   content = <<DOC
#   {
#     "schemaVersion": "1.2",
#     "description": "Check ip configuration of a Linux instance.",
#     "parameters": {

#     },
#     "runtimeConfig": {
#       "aws:runShellScript": {
#         "properties": [
#           {
#             "id": "0.aws:runShellScript",
#             "runCommand": ["ifconfig"]
#           }
#         ]
#       }
#     }
#   }
# DOC
# }


## aws ssm send-command --document-name "AWS-ApplyAnsiblePlaybooks" --document-version "1" --targets '[{"Key":"InstanceIds","Values":["i-004071201395542c3"]}]' --parameters '{"SourceType":["S3"],"SourceInfo":["{\n \"path\":\"https://s3.amazonaws.com/ssm-bucket-testing-1234/playbook.yml\"\n}"],"InstallDependencies":["True"],"PlaybookFile":["hello-world-playbook.yml"],"ExtraVariables":["SSM=True"],"Check":["False"],"Verbose":["-v"],"TimeoutSeconds":["3600"]}' --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "ssm-bucket-testing-1234" --output-s3-key-prefix "otput" --region ap-south-1 --profile=mayank