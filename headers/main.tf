locals {
  service = "${var.service}-headers"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_${var.service}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${local.service}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
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
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "headers" {
  filename      = var.filename
  function_name = "${local.service}-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "src/handlers/origin-response.handler"
  publish       = true

  source_code_hash = filebase64sha256(var.filename)

  runtime = "nodejs10.x"

  depends_on    = [aws_iam_role_policy_attachment.lambda_logs, aws_cloudwatch_log_group.logs]
}