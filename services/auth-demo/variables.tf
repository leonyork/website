variable "region" {
  default = "us-east-1"
}
variable "stage" {
  default = "dev"
}
variable "service" {
  default = "auth-demo"
}
variable "access_control_allow_origin" {
  default = "*"
}
variable "callback_urls" {
}
variable "logout_urls" {
}

variable "relative_path" {
  default = "./"
}