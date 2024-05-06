terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
  }

  required_version = ">= 1.2.0"
}

variable "scheduler_group_name" {}

resource "aws_scheduler_schedule_group" "ec2-scheduler" {
    name = var.scheduler_group_name
}
resource "aws_iam_role_policy" "scheduler_execution_policy" {
    name = "scheduler-execution-policy"
    role = aws_iam_role.scheduler_execution_role.id
    policy = jsonencode({
        Version: "2012-10-17"
        Statement: [
            {
                Effect: "Allow"
                Action: [
                    "lambda:InvokeFunction"
                ]
                Resource: [
                    "${module.start-stop-instances.lambda_function_arn}:*",
                    "${module.start-stop-instances.lambda_function_arn}"
                ]
            },
        ]
    })
}

resource "aws_iam_role" "scheduler_execution_role" {
    name = "scheduler-execution-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "scheduler.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
          }
        ]
    })
}

resource "aws_iam_role_policy" "scheduler-lambda-policy" {
    name = "scheduler-lambda-policy"
    role = aws_iam_role.scheduler_lambda_role.name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "ec2:Describe*",
              "ec2:StartInstances",
              "ec2:StopInstances"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "basic_lambda_policy" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    role = aws_iam_role.scheduler_lambda_role.name
}

resource "aws_iam_role" "scheduler_lambda_role" {
  name               = "scheduler-lambda-role"
  assume_role_policy = jsonencode({
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
  })
}

module "start-stop-instances" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "start-stop-instances"
  handler = "StartStopInstances.lambda_handler"
  runtime = "python3.11"
  timeout = 10

  create_role = false
  lambda_role = aws_iam_role.scheduler_lambda_role.arn

  source_path = "./python"
}
