variable "region" {
  default = "us-east-1"
}
variable "service" {
  default = "website"
}
variable "stage" {
  default = "dev"
}
variable "zone_id" {
}
variable "certificate_arn" {
}
variable "headers_deploy_zip" {
  default = "./headers/.serverless/headers.zip"
}
variable "domain" {

}