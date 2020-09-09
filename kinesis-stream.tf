resource "aws_kinesis_stream" "order_logs_stream" {
  name             = "${var.environment}-amnidhiorders"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = var.environment
  }
}


// lambda functiion to send the stream data to dynamoDB table created in dynamoDB.tf

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.environment}-iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_role_dynamoDB_policy" {
  name = "${var.environment}-lambda_role_dynamoDB_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<-EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": [
                  "dynamodb:*",
                  "dax:*",
                  "application-autoscaling:DeleteScalingPolicy",
                  "application-autoscaling:DeregisterScalableTarget",
                  "application-autoscaling:DescribeScalableTargets",
                  "application-autoscaling:DescribeScalingActivities",
                  "application-autoscaling:DescribeScalingPolicies",
                  "application-autoscaling:PutScalingPolicy",
                  "application-autoscaling:RegisterScalableTarget",
                  "cloudwatch:DeleteAlarms",
                  "cloudwatch:DescribeAlarmHistory",
                  "cloudwatch:DescribeAlarms",
                  "cloudwatch:DescribeAlarmsForMetric",
                  "cloudwatch:GetMetricStatistics",
                  "cloudwatch:ListMetrics",
                  "cloudwatch:PutMetricAlarm",
                  "datapipeline:ActivatePipeline",
                  "datapipeline:CreatePipeline",
                  "datapipeline:DeletePipeline",
                  "datapipeline:DescribeObjects",
                  "datapipeline:DescribePipelines",
                  "datapipeline:GetPipelineDefinition",
                  "datapipeline:ListPipelines",
                  "datapipeline:PutPipelineDefinition",
                  "datapipeline:QueryObjects",
                  "ec2:DescribeVpcs",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeSecurityGroups",
                  "iam:GetRole",
                  "iam:ListRoles",
                  "kms:DescribeKey",
                  "kms:ListAliases",
                  "sns:CreateTopic",
                  "sns:DeleteTopic",
                  "sns:ListSubscriptions",
                  "sns:ListSubscriptionsByTopic",
                  "sns:ListTopics",
                  "sns:Subscribe",
                  "sns:Unsubscribe",
                  "sns:SetTopicAttributes",
                  "lambda:CreateFunction",
                  "lambda:ListFunctions",
                  "lambda:ListEventSourceMappings",
                  "lambda:CreateEventSourceMapping",
                  "lambda:DeleteEventSourceMapping",
                  "lambda:GetFunctionConfiguration",
                  "lambda:DeleteFunction",
                  "resource-groups:ListGroups",
                  "resource-groups:ListGroupResources",
                  "resource-groups:GetGroup",
                  "resource-groups:GetGroupQuery",
                  "resource-groups:DeleteGroup",
                  "resource-groups:CreateGroup",
                  "tag:GetResources"
              ],
              "Effect": "Allow",
              "Resource": "*"
          },
          {
              "Action": "cloudwatch:GetInsightRuleReport",
              "Effect": "Allow",
              "Resource": "arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"
          },
          {
              "Action": [
                  "iam:PassRole"
              ],
              "Effect": "Allow",
              "Resource": "*",
              "Condition": {
                  "StringLike": {
                      "iam:PassedToService": [
                          "application-autoscaling.amazonaws.com",
                          "dax.amazonaws.com"
                      ]
                  }
              }
          },
          {
              "Effect": "Allow",
              "Action": [
                  "iam:CreateServiceLinkedRole"
              ],
              "Resource": "*",
              "Condition": {
                  "StringEquals": {
                      "iam:AWSServiceName": [
                          "replication.dynamodb.amazonaws.com",
                          "dax.amazonaws.com",
                          "dynamodb.application-autoscaling.amazonaws.com",
                          "contributorinsights.dynamodb.amazonaws.com"
                      ]
                  }
              }
          }
      ]
  }
 EOF
}

resource "aws_iam_role_policy" "lambda_role_kinesis_stream_policy" {
  name = "${var.environment}-lambda_role_kinesis_stream_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<-EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "kinesis:Get*",
                  "kinesis:List*",
                  "kinesis:Describe*"
              ],
              "Resource": "*"
          }
      ]
  }
 EOF
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.process_orders_lambda.function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.environment}-lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": [
         "logs:CreateLogGroup",
         "logs:CreateLogStream",
         "logs:PutLogEvents"
       ],
       "Resource": "arn:aws:logs:*:*:*",
       "Effect": "Allow"
     }
   ]
 }
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

// lambda zip file creation
data "archive_file" "bundle" {
  type       = "zip"
  source_dir = "${path.module}/lambda_files"

  output_path = "${path.module}/lambda_files_bundle/lambda.zip"
}

resource "aws_lambda_event_source_mapping" "kinesis_source_mapping" {
  event_source_arn  = aws_kinesis_stream.order_logs_stream.arn
  function_name     = aws_lambda_function.process_orders_lambda.arn
  starting_position = "LATEST"
}

resource "aws_lambda_function" "process_orders_lambda" {
  filename         = data.archive_file.bundle.output_path
  function_name    = "${var.environment}-process_orders"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "process_orders.lambda_handler"
  source_code_hash = data.archive_file.bundle.output_sha

  runtime = "python2.7"

  environment {
    variables = {
      DYNAMODBTABLE = "${var.environment}-AminidhiOrders"
    }
  }
}
