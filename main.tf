variable "region" {
  default = "us-east-1"
}
variable "stage" {
  default = "dev"
}
variable "service" {
  default = "leonyork-com"
}
variable "domain" {
  default = "leonyork.com"
}
variable "build" {
  default = "out"
}

provider "aws" {
  region = var.region
  version = "2.57.0"
}

terraform {
  required_version = ">= 0.12.18"
  backend "s3" {
    bucket = "prod-leonyork-com-terraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

module "certificate" {
  source = "./certificate"

  domain = var.domain
}

module "auth_demo" {
  source = "./services/auth-demo"

  region = var.region
  stage = var.stage
  service = var.service
  callback_urls = [module.client.redirect_url]
  logout_urls = [module.client.logout_url]
}

module "client" {
  source = "./client"

  region = var.region
  stage = var.stage
  service = var.service

  domain = var.domain
  zone_id = module.certificate.zone_id
  certificate_arn = module.certificate.certificate_arn

  headers_deploy_zip = "./client/headers/.serverless/headers.zip"
}

output "user_pool_id" {
  value = module.auth_demo.user_pool_id
}
output "user_pool_client_id" {
  value = module.auth_demo.user_pool_client_id
}
output "cognito_host" {
  value = module.auth_demo.cognito_host
}
output "token_issuer" {
  value = module.auth_demo.token_issuer
}
output "auth_demo_table_name" {
  value = module.auth_demo.auth_demo_table_name
}
output "s3_bucket_id" {
  value = module.client.s3_bucket_id
}
output "client_app_domain_name" {
  value = module.client.app_domain_name
}