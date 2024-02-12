terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
}

module "shared-resources" {
    source = "./modules/shared-resources"
    scheduler_group_name = var.scheduler_group_name
}

module "workday_start" {
    source = "./modules/schedule"
    scheduler_name = "workday-start"
    scheduler_group_name = var.scheduler_group_name
    schedule_expression = "cron(00 9 ? * 2-6 *)"
    scheduler_target_arn = module.shared-resources.start_stop_lambda_function_arn
    scheduler_target_role_arn = module.shared-resources.scheduler_execution_role_arn
    scheduler_target_input = jsonencode({
        start = true
        tag_name = "scheduler"
        tag_value = "dev"
    })
}

module "everyday_stop" {
    source = "./modules/schedule"
    scheduler_name = "everyday-stop"
    scheduler_group_name = var.scheduler_group_name
    schedule_expression = "cron(00 22 * * ? *)"
    scheduler_target_arn = module.shared-resources.start_stop_lambda_function_arn
    scheduler_target_role_arn = module.shared-resources.scheduler_execution_role_arn
    scheduler_target_input = jsonencode({
        start = false
        tag_name = "scheduler"
        tag_value = "dev"
    })
}
