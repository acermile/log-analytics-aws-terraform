resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "mycatalogdatabase"
}


resource "aws_glue_crawler" "order-data" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "${var.environment}-order-data"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.order-bucket.bucket}/${formatdate("YYYY/MM/DD", timestamp())}/"
    //exclusions = ["es/**"]
  }

  table_prefix = "${var.environment}-order-data"
}


resource "aws_iam_role" "glue_role" {
  name = "${var.environment}-glue_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
EOF

}

resource "aws_iam_role_policy" "glue_role_policy" {
  name = "${var.environment}-glue_role_policy"
  role = aws_iam_role.glue_role.id

  policy = <<-EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "glue:*",
                  "s3:GetBucketLocation",
                  "s3:ListBucket",
                  "s3:ListAllMyBuckets",
                  "s3:GetBucketAcl",
                  "ec2:DescribeVpcEndpoints",
                  "ec2:DescribeRouteTables",
                  "ec2:CreateNetworkInterface",
                  "ec2:DeleteNetworkInterface",
                  "ec2:DescribeNetworkInterfaces",
                  "ec2:DescribeSecurityGroups",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeVpcAttribute",
                  "iam:ListRolePolicies",
                  "iam:GetRole",
                  "iam:GetRolePolicy",
                  "cloudwatch:PutMetricData"
              ],
              "Resource": [
                  "*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:CreateBucket"
              ],
              "Resource": [
                  "arn:aws:s3:::aws-glue-*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject"
              ],
              "Resource": [
                  "arn:aws:s3:::*",
                  "arn:aws:s3:::*/*aws-glue-*/*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "s3:GetObject"
              ],
              "Resource": [
                  "arn:aws:s3:::crawler-public*",
                  "arn:aws:s3:::aws-glue-*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": [
                  "arn:aws:logs:*:*:/aws-glue/*"
              ]
          },
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:CreateTags",
                  "ec2:DeleteTags"
              ],
              "Condition": {
                  "ForAllValues:StringEquals": {
                      "aws:TagKeys": [
                          "aws-glue-service-resource"
                      ]
                  }
              },
              "Resource": [
                  "arn:aws:ec2:*:*:network-interface/*",
                  "arn:aws:ec2:*:*:security-group/*",
                  "arn:aws:ec2:*:*:instance/*"
              ]
          }
      ]
  }
 EOF
}
