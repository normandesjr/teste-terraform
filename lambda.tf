resource "aws_iam_role" "lambda_exec_role" {
    name = "LambdaExecRole"

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

resource "aws_iam_role_policy_attachment" "aws_lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "test_lambda_function" {
    function_name   = "TestLambdaFunction"

    filename      = "my-lambda.zip"

    source_code_hash = filebase64sha256("my-lambda.zip")

    handler         = "lambda_function.lambda_handler"
    runtime         = "python3.8"

    role            = aws_iam_role.lambda_exec_role.arn

    reserved_concurrent_executions = 50
    
    vpc_config {
        subnet_ids          = data.aws_subnet_ids.subnets.ids
        security_group_ids  = [aws_security_group.database.id]
    }

    environment {
      variables = {
        "DB_ENDPOINT" = "${module.db.db_instance_endpoint}"
        "DB_USERNAME" = "${module.db.db_instance_username}"
        "DB_PASSWORD" = "${module.db.db_instance_password}"
      }
    }
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_event_source_mapping" "test_event_source" {
  event_source_arn = aws_sqs_queue.test_sqs_1.arn
  enabled = true
  function_name    = aws_lambda_function.test_lambda_function.arn
}

resource "aws_iam_policy" "dynamo" {
  name        = "test-dynamo-policy"
  description = "Test Dynamo policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.test_dynamo.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamo.arn
}

resource "aws_iam_policy" "s3" {
  name        = "test-s3-policy"
  description = "Test s3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.test_bucket.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_s3_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.s3.arn
}
