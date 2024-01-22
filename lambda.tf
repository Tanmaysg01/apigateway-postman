resource "aws_s3_bucket" "example" {
  bucket = "lambda-store-bucket-2024"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_api_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_api_policy"
  description = "Policy for Lambda Execution"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
            Effect = "Allow",
            Action = [
                "s3:*",
                "s3-object-lambda:*"
            ],
            Resource = "*"
      },
      {
            Effect = "Allow",
            Action = [
                "apigateway:*"
            ],
            Resource = "arn:aws:apigateway:*::/*"
      },
      {
            Effect  = "Allow",
            Action  = [
                "cloudformation:DescribeStacks",
                "cloudformation:ListStackResources",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:ListAliases",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "lambda:*",
                "logs:DescribeLogGroups",
                "states:DescribeStateMachine",
                "states:ListStateMachines",
                "tag:GetResources",
                "xray:GetTraceSummaries",
                "xray:BatchGetTraces"
            ],
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "Outputs/lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "Outputs/lambda.zip"
  function_name = "api-lambda-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/${aws_api_gateway_method.MyDemoMethod.http_method}${aws_api_gateway_resource.MyDemoResource.path}"
}