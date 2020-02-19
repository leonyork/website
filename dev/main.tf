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

module "cognito" {
  source = "../services/auth-demo/iam/cognito"

  region = var.region
  stage = local.stage
  service = local.service
  callback_urls = local.callback_urls
  logout_urls = local.logout_urls
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