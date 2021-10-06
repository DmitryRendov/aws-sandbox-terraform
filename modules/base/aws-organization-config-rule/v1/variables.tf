variable "aws_account_ids" {
  type = list(string)
}
variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "name" {
  description = "Name of the org config rule"
  type        = string
}

variable "description" {
  description = "Description for the org config rule"
  type        = string
}

variable "label" {
  description = "Single `label` resource for setting context and tagging resources. Typically this will be something like `module.label`."
}

variable "label_attributes" {
  description = "Additional label attributes (e.g. policy or role)"
  default     = []
  type        = list(string)
}

variable "input_parameters" {
  description = "The parameters are passed to the AWS Config Rule Lambda Function in JSON format."
  default     = {}
}

variable "exclude_accounts" {
  description = "List of AWS account identifiers to exclude from the rules"
  default     = []
  type        = list(string)
}

variable "maximum_execution_frequency" {
  default     = "TwentyFour_Hours"
  description = "The maximum frequency with which AWS Config runs evaluations for a rule."
}

variable "org_lambda_role_id" {
  description = "The name of a shared IAM role to run ORG Config Lambda Function."
  type        = string
}

variable "org_lambda_cross_account_role_id" {
  description = "The name of a shared IAM role that Audit ORG Config Lambda Function assumes in other AWS accounts."
  type        = string
}

variable "alarm_enabled" {
  description = "Create the Cloudwatch Alarm or not"
  default     = true
  type        = bool
}

variable "alarm_actions" {
  description = "Actions to take if there are errors in the lambda function"
  default     = []
  type        = list(string)
}

variable "alarm_period" {
  description = "The period in seconds over which the alarm statistic is applied"
  default     = "86400" # 24 * 60 * 60"
}

variable "alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified alarm threshold"
  default     = "1"
}

variable "alarm_threshold" {
  description = "The value against which the specified statistic is compared."
  default     = "1"
}

variable "treat_missing_data" {
  description = "Sets how to handle missing data points"
  default     = "missing"
}

variable "log_retention" {
  description = "Maximum days of log retention for the lambda function log group"
  default     = 30
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds. Defaults to 600"
  default     = 600
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128"
  default     = 128
}

variable "trigger_types" {
  description = "List of notification types that trigger AWS Config to run an evaluation for the rule. Valid values: ConfigurationItemChangeNotification, OversizedConfigurationItemChangeNotification, and ScheduledNotification"
  default     = ["ScheduledNotification"]
  type        = list(string)
}

variable "lambda_environment_variables" {
  description = "Map of environment variables to pass to the config check lambda"
  default = {
    LOG_LEVEL = "INFO"
  }
  type = map(string)
}

variable "lambda_handler" {
  description = "Handler for the config check lambda"
  type        = string
}

variable "archive_file" {
  description = "A `archive_file` data resource for the lambda file."
}

variable "s3_bucket" {
  description = "Amazon S3 bucket name where the .zip file containing your deployment package is stored"
  default     = null
}

variable "s3_key" {
  description = "The Amazon S3 object (the deployment package) key name you want to upload"
  default     = null
}
