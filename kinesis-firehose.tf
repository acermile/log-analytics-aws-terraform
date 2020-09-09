resource "aws_s3_bucket" "order-bucket" {
  bucket = "orderlogs-${var.AWS_PROFILE}"
  acl    = "private"
}

resource "aws_iam_role_policy" "firehose_role_policy" {
  name = "firehose_role_policy"
  role = aws_iam_role.firehose_role.id

  policy = <<-EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "glue:GetTable",
                    "glue:GetTableVersion",
                    "glue:GetTableVersions"
                ],
                "Resource": [
                    "arn:aws:glue:us-east-1:942960519349:catalog",
                    "arn:aws:glue:us-east-1:942960519349:database/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%",
                    "arn:aws:glue:us-east-1:942960519349:table/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
                ]
            },
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "s3:AbortMultipartUpload",
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:ListBucketMultipartUploads",
                    "s3:PutObject"
                ],
                "Resource": [
                    "arn:aws:s3:::orderlogs-csa",
                    "arn:aws:s3:::orderlogs-csa/*"
                ]
            },
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "lambda:InvokeFunction",
                    "lambda:GetFunctionConfiguration"
                ],
                "Resource": "arn:aws:lambda:us-east-1:942960519349:function:%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:GenerateDataKey",
                    "kms:Decrypt"
                ],
                "Resource": [
                    "arn:aws:kms:us-east-1:942960519349:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
                ],
                "Condition": {
                    "StringEquals": {
                        "kms:ViaService": "s3.us-east-1.amazonaws.com"
                    },
                    "StringLike": {
                        "kms:EncryptionContext:aws:s3:arn": [
                            "arn:aws:s3:::%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%/*"
                        ]
                    }
                }
            },
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:us-east-1:942960519349:log-group:/aws/kinesisfirehose/PurchaseLogs:log-stream:*"
                ]
            },
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "kinesis:DescribeStream",
                    "kinesis:GetShardIterator",
                    "kinesis:GetRecords",
                    "kinesis:ListShards"
                ],
                "Resource": "arn:aws:kinesis:us-east-1:942960519349:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:Decrypt"
                ],
                "Resource": [
                    "arn:aws:kms:us-east-1:942960519349:key/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
                ],
                "Condition": {
                    "StringEquals": {
                        "kms:ViaService": "kinesis.us-east-1.amazonaws.com"
                    },
                    "StringLike": {
                        "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:us-east-1:942960519349:stream/%FIREHOSE_POLICY_TEMPLATE_PLACEHOLDER%"
                    }
                }
            }
        ]
  }
  EOF
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "firehose.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
]
}
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "purchaselogs" {
  name        = "PurchaseLogs"
  destination = "s3"

  s3_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.order-bucket.arn
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "purchaselogs"
      log_stream_name = "purchaselogs"
    }
  }
}
