
locals {
    api_path = "${path.module}/api"
    api_url_file_location = "/api-url"
}

module "cognito" {
  source = "./iam/cognito"

  region = "${var.region}"
  stage = "${var.stage}"
  service = "${var.service}"
  callback_urls = var.callback_urls
  logout_urls = var.logout_urls
}

data "template_file" "api_url_file" {
    template = "${local.api_url_file_location}"
}

resource "null_resource" "build-and-deploy-back-end" {
  depends_on = ["module.cognito"]

  #Ensure we run this build and deploy every time - even if the other resources didn't need to be changed - This is a known hack - see https://www.kecklers.com/terraform-null-resource-execute-every-time/ and https://github.com/hashicorp/terraform/pull/3244
  triggers = {
      build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    ROOT_DIR=$(pwd)
    cd ${local.api_path} && \
    apk add --update nodejs npm jq && \
    npm install && \
    USER_STORE_API_SECURED_ISSUER=${module.cognito.token_issuer} \
    USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN=https://${var.access_control_allow_origin} \
    npm run deploy -- --stage=${var.stage} --region=${var.region} && \
    SERVICE_NAME=$(grep "^service: .*$" serverless.yml | cut -f2 -d ' ')
    cd $ROOT_DIR && \
    aws cloudformation describe-stacks --stack-name $SERVICE_NAME-${var.stage} --region ${var.region} --output json | jq '.Stacks[0].Outputs[] | select(.OutputKey == "ApiUrl") | .OutputValue' -rj > ${data.template_file.api_url_file.rendered}
    EOF
  }
}

data "local_file" "api_url" {
    depends_on = ["null_resource.build-and-deploy-back-end"]
    filename = "${data.template_file.api_url_file.rendered}"
}