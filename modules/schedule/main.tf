terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
  }

  required_version = ">= 1.2.0"
}

variable "scheduler_name" {}
variable "scheduler_group_name" {}
variable "schedule_expression" {}
variable "schedule_expression_timezone" {
  default = "UTC"
}
variable "scheduler_target_arn" {}
variable "scheduler_target_role_arn" {}
variable "scheduler_target_input" {}

resource "aws_scheduler_schedule" "schedule" {
  name                         = var.scheduler_name
  group_name                   = var.scheduler_group_name
  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.scheduler_target_arn
    role_arn = var.scheduler_target_role_arn
    input    = var.scheduler_target_input
  }
}