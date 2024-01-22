resource "aws_s3_bucket" "example2" {
  bucket = "lambda2-store-bucket-2024"
}

resource "aws_iam_role" "lambda2_api_role" {
  name = "lambda2_api_role"

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

resource "aws_iam_policy" "lambda2_api_policy" {
  name        = "lambda2_api_policy"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment2" {
  policy_arn = aws_iam_policy.lambda2_api_policy.arn
  role       = aws_iam_role.lambda2_api_role.name
}

data "archive_file" "lambdaapi" {
  type        = "zip"
  source_file = "lambdaapi.py"
  output_path = "Outputs/lambdaapi.zip"
}

resource "aws_lambda_function" "test2_lambda" {
  filename      = "Outputs/lambdaapi.zip"
  function_name = "api-lambda-function-2"
  role          = aws_iam_role.lambda2_api_role.arn
  handler       = "lambdaapi.lambda_handler"

  source_code_hash = data.archive_file.lambdaapi.output_base64sha256

  runtime = "python3.8"
}

resource "aws_lambda_permission" "apigw_lambda2" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test2_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  
 source_arn = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/${aws_api_gateway_method.MyDemoMethod2.http_method}${aws_api_gateway_resource.MyDemoResource.path}"
}