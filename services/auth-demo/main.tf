locals {
  service = "${var.service}-auth-demo"
}

module "cognito" {
  source = "./iam/cognito"

  region = "${var.region}"
  stage = "${var.stage}"
  service = "${local.service}"
  callback_urls = var.callback_urls
  logout_urls = var.logout_urls
}

module "api" {
  source = "./api"

  region = "${var.region}"
  stage = "${var.stage}"
  service = "${local.service}"
  access_control_allow_origin = "${var.access_control_allow_origin}"
  token_issuer="${module.cognito.token_issuer}"
}