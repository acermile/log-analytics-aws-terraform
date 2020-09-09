resource "aws_s3_bucket" "query-results" {
  bucket = "${var.environment}-query-results-csa"
  acl    = "private"
}

/*resource "aws_athena_database" "fromglue" {
  name   = aws_glue_catalog_database.aws_glue_catalog_database.name
  bucket = aws_s3_bucket.order-bucket.bucket
}*/



/*resource "aws_kms_key" "test" {
  deletion_window_in_days = 7
  description             = "Athena KMS Key"
}*/

resource "aws_athena_workgroup" "order-results" {
  name = "${var.environment}-order-results"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.query-results.bucket}/output/"
      /*  encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.test.arn
      }*/
    }
  }
}



resource "aws_athena_named_query" "named-query" {
  name      = "preview-orders"
  workgroup = aws_athena_workgroup.order-results.id
  database  = aws_glue_catalog_database.aws_glue_catalog_database.name
  query     = "SELECT * FROM ${aws_glue_catalog_database.aws_glue_catalog_database.name} limit 10;"
}
