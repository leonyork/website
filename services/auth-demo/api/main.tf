
locals {
    api_path = path.module
    api_url_file_location = "/api-url"
}

module "dynamodb" {
  source = "./dynamodb"

  region = var.region
  stage = var.stage
  service = var.service
}

data "template_file" "api_url_file" {
    template = local.api_url_file_location
}

resource "null_resource" "build_and_deploy_back_end" {
  #Ensure we run this build and deploy every time - even if the other resources didn't need to be changed - This is a known hack - see https://www.kecklers.com/terraform-null-resource-execute-every-time/ and https://github.com/hashicorp/terraform/pull/3244
  triggers = {
      build_number = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
    set -eux && \
    cd ${local.api_path} && \
    make deploy
    EOF

    environment = {
      REGION = var.region
      STAGE = var.stage
      USERS_TABLE = module.dynamodb.table_name
      USER_STORE_API_SECURED_ISSUER = var.token_issuer
      USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN = "https://${var.access_control_allow_origin}"
    }
  }
}

resource "null_resource" "get_serverless_stack_details" {
  depends_on = [null_resource.build_and_deploy_back_end]

  #Ensure we run this build and deploy every time - even if the other resources didn't need to be changed - This is a known hack - see https://www.kecklers.com/terraform-null-resource-execute-every-time/ and https://github.com/hashicorp/terraform/pull/3244
  triggers = {
      build_number = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
    set -eux && \
    SERVICE_NAME=$(grep "^service: .*$" ${local.api_path}/serverless.yml | cut -f2 -d ' ') 
    aws cloudformation describe-stacks --stack-name $SERVICE_NAME-${var.stage} --region ${var.region} --output json | jq '.Stacks[0].Outputs[] | select(.OutputKey == "ApiUrl") | .OutputValue' -rj > ${data.template_file.api_url_file.rendered}
    EOF
  }
}

data "local_file" "api_url" {
    depends_on = [null_resource.get_serverless_stack_details]
    filename = data.template_file.api_url_file.rendered
}