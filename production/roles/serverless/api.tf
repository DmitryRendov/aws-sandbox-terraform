##
# API Gateway
#

resource "aws_api_gateway_rest_api" "public_api" {
  name = local.api_gateway_name

  endpoint_configuration {
    types = [local.api_type]
  }
  tags = module.label.tags

}

resource "aws_api_gateway_gateway_response" "gateway_response_default_bad_request" {
  rest_api_id   = aws_api_gateway_rest_api.public_api.id
  response_type = "BAD_REQUEST_BODY"
  status_code   = "400"

  response_templates = {
    "application/json" = "{\"message\":$context.error.validationErrorString}"
  }
}

resource "aws_api_gateway_gateway_response" "gateway_response_default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.public_api.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
  }

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }
}

##
# API Gateway Mock for integration
#

resource "aws_api_gateway_resource" "public_api_gateway_mocks" {
  rest_api_id = aws_api_gateway_rest_api.public_api.id
  parent_id   = aws_api_gateway_rest_api.public_api.root_resource_id
  path_part   = "mocks"
}

resource "aws_api_gateway_method" "public_api_gateway_mock_method" {
  rest_api_id   = aws_api_gateway_rest_api.public_api.id
  resource_id   = aws_api_gateway_resource.public_api_gateway_mocks.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "public_api_gateway_mock_integration" {
  rest_api_id          = aws_api_gateway_rest_api.public_api.id
  resource_id          = aws_api_gateway_resource.public_api_gateway_mocks.id
  http_method          = aws_api_gateway_method.public_api_gateway_mock_method.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.public_api.id
  resource_id = aws_api_gateway_resource.public_api_gateway_mocks.id
  http_method = aws_api_gateway_method.public_api_gateway_mock_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "public_api_gateway_mock_method_response" {
  rest_api_id = aws_api_gateway_rest_api.public_api.id
  resource_id = aws_api_gateway_resource.public_api_gateway_mocks.id
  http_method = aws_api_gateway_method.public_api_gateway_mock_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = "{\"apiVersion\": \"${local.api_version}\", \"statusCode\": \"200\"}"
  }
}

resource "aws_api_gateway_deployment" "public_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.public_api.id
  stage_name  = terraform.workspace
  depends_on  = [aws_api_gateway_integration.public_api_gateway_mock_integration]
}

##
# API Gateway Logs
#

resource "aws_cloudwatch_log_group" "public_api_log_group" {
  name              = "${module.label.id}-API-Gateway-Access-Logs_${aws_api_gateway_rest_api.public_api.id}/${aws_api_gateway_deployment.public_api_gateway_deployment.stage_name}"
  retention_in_days = local.api_logs_retention_in_days
  tags              = module.label.tags
}

resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = aws_api_gateway_rest_api.public_api.id
  stage_name  = aws_api_gateway_deployment.public_api_gateway_deployment.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = local.api_metrics_enabled
    data_trace_enabled = local.api_data_trace_enabled
    logging_level      = local.api_logging_level

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = local.api_throttling_rate_limit
    throttling_burst_limit = local.api_throttling_burst_limit
  }

  depends_on = [aws_api_gateway_deployment.public_api_gateway_deployment]
}
