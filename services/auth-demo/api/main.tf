module "dynamodb" {
  source = "./dynamodb"

  region = var.region
  stage = var.stage
  service = var.service
}