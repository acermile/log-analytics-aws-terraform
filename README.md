# Serverless log analytics using kinesis , glue and athena.

<img src="/aws-logs.png" width="100%" alt="aws-logs" title="aws-logs">

...................


- aws_athena_named_query.named-query: Creating...
- aws_kinesis_firehose_delivery_stream.purchaselogs: Still creating... [50s elapsed]
- aws_athena_named_query.named-query: Creation complete after 5s [id=a213b33f-dc6e-4575-9874-2a357e9ee870]
-  aws_kinesis_firehose_delivery_stream.purchaselogs: Creation complete after 52s [id=arn:aws:firehose:us-east-1:942960519349:deliverystream/PurchaseLogs]
-  aws_kinesis_stream.order_logs_stream: Still creating... [1m0s elapsed]
-  aws_kinesis_stream.order_logs_stream: Still creating... [1m10s elapsed]
-  aws_kinesis_stream.order_logs_stream: Creation complete after 1m10s [id=arn:aws:kinesis:us-east-1:942960519349:stream/uat-amnidhiorders]
- aws_lambda_event_source_mapping.kinesis_source_mapping: Creating...
8. aws_lambda_event_source_mapping.kinesis_source_mapping: Creation complete after 6s [id=8f5a0dfb-642c-464a-8937-429ba90653ea]
-  aws_instance.kinesis-host-ec2: Still creating... [10s elapsed]
-  aws_instance.kinesis-host-ec2: Still creating... [20s elapsed]
- aws_instance.kinesis-host-ec2: Still creating... [30s elapsed]
-  aws_instance.kinesis-host-ec2: Still creating... [40s elapsed]
-  aws_instance.kinesis-host-ec2: Creation complete after 48s [id=i-0bdef1db7ea1028e8]

Apply complete! Resources: 25 added, 0 changed, 0 destroyed.
