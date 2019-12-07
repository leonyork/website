output "user_pool_id" {
  value = "${module.cognito.user_pool_id}"
}
output "user_pool_client_id" {
  value = "${module.cognito.user_pool_client_id}"
}
output "token_issuer" {
  value = "${module.cognito.token_issuer}"
}
output "cognito_host" {
  value = "${module.cognito.cognito_host}"
}
output "api_url" {
  value = "${module.api.api_url}"
}
