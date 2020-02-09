
module "headers" {
  source = "./headers"

  region = var.region
  stage = var.stage
  service = var.service

  filename = var.headers_deploy_zip
}

module "client_app" {
  source = "./app"

  region = var.region
  stage = var.stage

  zone_id = var.zone_id
  certificate_arn = var.certificate_arn
  origin_response_lambda_arn = module.headers.qualified_arn
  domain = var.domain
}