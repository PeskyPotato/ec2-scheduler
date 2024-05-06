output "start_stop_lambda_function_arn" {
    description = "ARN of the Lambda function triggered to stop or stop EC2 instances."
    value  = module.start-stop-instances.lambda_function_arn
}

output "scheduler_execution_role_arn" {
    description = "ARN of the EventBridge Scheduler execution role."
    value = aws_iam_role.scheduler_execution_role.arn
}