variable "region" {
  default = "us-east-1"
}
provider "aws" {
  region = var.region
  version = "2.47.0"
}
provider "random" {
  version = "2.2"
}
terraform {
  required_version = ">= 0.12.18"
}

resource "random_id" "service_name" {
  byte_length = 8
}

locals {
  service = "leonyork-com-${random_id.service_name.hex}"
  stage = "dev"
  callback_urls = ["http://localhost:3000/auth-demo"]
  logout_urls = ["http://localhost:3000/auth-demo"]
}

module "cognito_sign_up" {
  source = "./cognito-sign-up"

  region = var.region
  stage = local.stage
  service = local.service

  filename = "./cognito-sign-up/.serverless/cognito-sign-up.zip"
}

module "cognito" {
  source = "./cognito"

  region = var.region
  stage = local.stage
  service = local.service
  callback_urls = local.callback_urls
  logout_urls = local.logout_urls
  pre_sign_up_lambda_arn = module.cognito_sign_up.arn
}

resource "aws_lambda_permission" "allow_cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_sign_up.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito.user_pool_arn
}


output "user_pool_id" {
  value = module.cognito.user_pool_id
}
output "user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}
output "token_issuer" {
  value = module.cognito.token_issuer
}
output "cognito_host" {
  value = module.cognito.cognito_host
}