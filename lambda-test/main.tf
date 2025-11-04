terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }

  backend "s3" {
    key = "state/s3/project-terraform.tfstate"
  }
}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "patrick"
  region                   = var.aws_region
}

# Package Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

# --- IAM ROLE FOR LAMBDA ---
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

# Basic logs
resource "aws_iam_role_policy_attachment" "basic_logging" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Bedrock invoke permissions (runtime only)
resource "aws_iam_policy" "bedrock_invoke_policy" {
  name        = "${var.project}-bedrock-invoke"
  description = "Allow Lambda to invoke Amazon Bedrock models and read logging config"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "InvokeModel"
        Effect   = "Allow"
        Action   = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:GetModelInvocationLoggingConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_invoke_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.bedrock_invoke_policy.arn
}

# Pre-create the log group used above (and Lambda's log group)
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project}-handler"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/invocations"
  retention_in_days = 14
}

# --- LAMBDA FUNCTION ---
resource "aws_lambda_function" "app" {
  function_name    = "${var.project}-handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler       = "handler.handler"
  runtime       = "python3.12"
  timeout       = 15
  memory_size   = 256
  architectures = ["x86_64"]

  environment {
    variables = {
      BEDROCK_REGION = var.bedrock_region
      MODEL_ID       = var.model_id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic_logging,
    aws_iam_role_policy_attachment.bedrock_invoke_attach,
    aws_cloudwatch_log_group.lambda_logs
  ]
}

# Public Function URL to hit Lambda with POST from the browser or curl
resource "aws_lambda_function_url" "app_url" {
  function_name      = aws_lambda_function.app.arn
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["*"]
    max_age       = 3600
  }
}

resource "aws_lambda_permission" "allow_public" {
  statement_id            = "AllowPublicFunctionUrlInvoke"
  action                  = "lambda:InvokeFunctionUrl"
  function_name           = aws_lambda_function.app.function_name
  principal               = "*"
  function_url_auth_type  = "NONE"
}
