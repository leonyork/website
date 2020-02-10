variable "region" {
  type = string
  default = "us-east-1"
}
variable "stage" {
  type = string
  default = "dev"
}
variable "service" {
  type = string
  default = "auth-demo"
}
variable "callback_urls" {
  type = list(string)
}
variable "logout_urls" {
  type = list(string)
}
variable "pre_sign_up_lambda_arn" {
  type = string
  default = ""
}