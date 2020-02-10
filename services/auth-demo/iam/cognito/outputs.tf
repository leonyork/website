output "user_pool_id" {
  value = "${aws_cognito_user_pool.pool.id}"
}
output "user_pool_arn" {
  value = "${aws_cognito_user_pool.pool.arn}"
}
output "user_pool_client_id" {
  value = "${aws_cognito_user_pool_client.client.id}"
}
output "token_issuer" {
  value = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
}
output "cognito_host" {
  value = "${var.stage}-${var.service}.auth.${var.region}.amazoncognito.com"
}