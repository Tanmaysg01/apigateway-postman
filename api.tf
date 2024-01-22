resource "aws_iam_role" "api_role" {
  name = "api_gateway_example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_policy" {
  name        = "_api_policy"
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

resource "aws_iam_role_policy_attachment" "api_policy_attachment" {
  policy_arn = aws_iam_policy.api_policy.arn
  role       = aws_iam_role.api_role.name
}
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "mydemoresource"
}



resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "test" {
  stage_name    = "apistage"
  rest_api_id   = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  deployment_id = "${aws_api_gateway_deployment.MyDemoDeployment.id}"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id             = "${aws_api_gateway_resource.MyDemoResource.id}"
  http_method             = "${aws_api_gateway_method.MyDemoMethod.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test_lambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = [ aws_api_gateway_method.MyDemoMethod ]

  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  stage_name  = "stage"

  variables = {
    "answer" = "42"
  }
}

resource "aws_api_gateway_method" "MyDemoMethod2" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration2" {
  rest_api_id             = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id             = "${aws_api_gateway_resource.MyDemoResource.id}"
  http_method             = "${aws_api_gateway_method.MyDemoMethod2.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test2_lambda.invoke_arn}"
}