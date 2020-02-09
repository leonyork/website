resource "aws_cognito_user_pool" "pool" {
  name = "${var.stage}-${var.service}"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length = 6
    require_symbols = false
    require_uppercase = false
  }
  lambda_config {
    pre_sign_up = var.pre_sign_up_lambda_arn
  }
}
resource "aws_cognito_user_pool_client" "client" {
  name = "${var.stage}-${var.service}"
  user_pool_id = aws_cognito_user_pool.pool.id
  generate_secret = false
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["openid"]
  callback_urls = var.callback_urls
  logout_urls = var.logout_urls
}

resource "aws_cognito_user_pool_domain" "pool-domain" {
  domain = "${var.stage}-${var.service}"
  user_pool_id = aws_cognito_user_pool.pool.id
}