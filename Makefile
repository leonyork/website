##########################
# Includes
##########################
include dev/Makefile
RELATIVE_DIR_DEV=./dev/

##########################
# Versions
##########################
TERRAFORM_VERSION=0.12.20
AWSCLI_VERSION=1.17.13-alpine3.11.3
ALPINE_VERSION=3.11.3
COMMIT_LINT_VERSION=8.3.5

##########################
# Variables
##########################
# Stage can be anything, although "production" is reserved for the production deployment (unless this is in a separate account)
export STAGE=dev
export REGION=us-east-1
DOMAIN=

STAGE_PRODUCTION=production
DOMAIN_PRODUCTION=leonyork.com
MAKE_PRODUCTION_ARGS=STAGE=$(STAGE_PRODUCTION) DOMAIN=$(DOMAIN_PRODUCTION)

STAGE_E2E=e2e
DOMAIN_E2E=
MAKE_E2E_ARGS=STAGE=$(STAGE_E2E) DOMAIN=$(DOMAIN_E2E)

##########################
# Commands
##########################
TERRAFORM_DOCKER_RUN_OPTIONS=-v $(CURDIR):/app \
	-w /app \
	-e "AWS_SECRET_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
	-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
	-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
	-it
TERRAFORM_DOCKER_IMAGE=hashicorp/terraform:$(TERRAFORM_VERSION)
TERRAFORM=docker run --rm $(TERRAFORM_DOCKER_RUN_OPTIONS) $(TERRAFORM_DOCKER_IMAGE)
TERRAFORM_SH=docker run --rm $(TERRAFORM_DOCKER_RUN_OPTIONS) --entrypoint sh $(TERRAFORM_DOCKER_IMAGE)
TERRAFORM_VARS=-var "stage=$(STAGE)" -var "domain=$(DOMAIN)" -var "region=$(REGION)"

AWS_CLI=docker run --rm \
	-e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)" \
	-e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" \
	leonyork/awscli:$(AWSCLI_VERSION)

ALPINE=docker run --rm -v $(CURDIR):/app -w /app alpine:$(ALPINE_VERSION)
DOCKER_COMPOSE_E2E=docker-compose -f e2e/e2e.docker-compose.yml
E2E=$(DOCKER_COMPOSE_E2E) -p leonyork-com-e2e

DOCKER_COMPOSE_E2E_LIGHTHOUSE=docker-compose -f e2e/e2e-lighthouse.docker-compose.yml
E2E_LIGHTHOUSE=$(DOCKER_COMPOSE_E2E_LIGHTHOUSE) -p leonyork-com-e2e-lighthouse

DOCKER_COMPOSE_E2E_OBSERVATORY=docker-compose -f e2e/e2e-observatory.docker-compose.yml
E2E_OBSERVATORY=$(DOCKER_COMPOSE_E2E_OBSERVATORY) -p leonyork-com-e2e-observatory


COMMIT_LINT_DOCKER_IMAGE=gtramontina/commitlint:$(COMMIT_LINT_VERSION) 
COMMIT_LINT_VARS=--edit
COMMIT_LINT=docker run --rm -v $(CURDIR)/.git:/app/.git -v $(CURDIR)/commitlint.config.js:/app/commitlint.config.js -w /app $(COMMIT_LINT_DOCKER_IMAGE) $(COMMIT_LINT_VARS)

##########################
# Terraform outputs
# Need to be run in shell
##########################
COGNITO_HOST=$(TERRAFORM) output cognito_host
USER_POOL_ID=$(TERRAFORM) output user_pool_id
CLIENT_ID=$(TERRAFORM) output user_pool_client_id
TOKEN_ISSUER=$(TERRAFORM) output token_issuer
AUTH_DEMO_TABLE_NAME=$(TERRAFORM) output auth_demo_table_name
S3_BUCKET_ID=$(TERRAFORM) output s3_bucket_id
CLIENT_APP_DOMAIN_NAME=$(TERRAFORM) output client_app_domain_name

##########################
# Sub-makes
##########################
CLIENT_DIR=client
SERVICES_DIR=services
SERVICE_AUTH_DEMO_API=services/auth-demo/api

AUTH_DEMO_API_DIR=services/auth-demo/api
AUTH_DEMO_API_SERVICE_NAME=$(ALPINE) sh -c "grep \"^service: .*$$\" $(AUTH_DEMO_API_DIR)/serverless.yml | cut -f2 -d ' '"
AUTH_DEMO_API_URL=$(AWS_CLI) cloudformation describe-stacks \
		--stack-name $(shell $(AUTH_DEMO_API_SERVICE_NAME))-$(STAGE) \
		--region $(REGION) \
		--output text \
		--query "Stacks[0].Outputs[?OutputKey=='ServiceEndpoint'].OutputValue"

##########################
# External targets
##########################

# Run unit tests
.PHONY: unit
unit: services-unit;

# Run integration tests
.PHONY: integration
integration: services-integration;

# Deploy the production infrastructure to production
.PHONY: infra-prod
infra-prod: 
	make $(MAKE_PRODUCTION_ARGS) -C . infra

# Deploy production apps onto the production infrastructure
.PHONY: deploy-prod
deploy-prod: 
	make $(MAKE_PRODUCTION_ARGS) -C . deploy

# Deploy on to the infra
# Need to run the deployment of the services before the app deployment (so that we can get URLs of the services to call)
.PHONY: deploy
deploy: services-deploy	
	make AUTH_DEMO_API_URL=$(shell $(AUTH_DEMO_API_URL)) TOKEN_ISSUER=$(shell $(TOKEN_ISSUER)) COGNITO_HOST=$(shell $(COGNITO_HOST)) CLIENT_ID=$(shell $(CLIENT_ID)) AUTH_DEMO_TABLE_NAME=$(shell $(AUTH_DEMO_TABLE_NAME)) S3_BUCKET_ID=$(shell $(S3_BUCKET_ID)) DOMAIN=$(shell $(CLIENT_APP_DOMAIN_NAME)) -C $(CLIENT_DIR) app-deploy

# Run the end2end tests
.PHONY: e2e
e2e: export CYPRESS_baseUrl=https://$(shell $(CLIENT_APP_DOMAIN_NAME))
e2e: export E2E_USER_POOL_ID=$(shell $(USER_POOL_ID))
e2e: export E2E_COGNITO_HOST=$(shell $(COGNITO_HOST))
e2e: export E2E_CLIENT_ID=$(shell $(CLIENT_ID))
e2e: e2e-build
	$(E2E) up --remove-orphans --force-recreate --abort-on-container-exit --exit-code-from e2e

# Run the lighthouse end2end tests
.PHONY: e2e-lighthouse
e2e-lighthouse: export BASE_URL=https://$(shell $(CLIENT_APP_DOMAIN_NAME))
e2e-lighthouse: e2e-lighthouse-pull
	$(E2E_LIGHTHOUSE) up --remove-orphans --force-recreate --abort-on-container-exit --exit-code-from e2e

# Run the observatory end2end tests
.PHONY: e2e-observatory
e2e-observatory: export BASE_URL=$(shell $(CLIENT_APP_DOMAIN_NAME))
e2e-observatory: e2e-observatory-pull
	$(E2E_OBSERVATORY) up --remove-orphans --force-recreate --abort-on-container-exit --exit-code-from e2e


.PHONY: destroy-prod
destroy-prod:
	make $(MAKE_PRODUCTION_ARGS) -C . destroy

# Only need to destroy the services as the front end will be taken care of by destroying the infrastructure
.PHONY: destroy
destroy: destroy-client destroy-services .terraform-plan-destroy
	@$(TERRAFORM) apply -auto-approve -input=false .terraform-plan-destroy
	@$(TERRAFORM) destroy -auto-approve -input=false -force
	@$(TERRAFORM) workspace select default
	@$(TERRAFORM) workspace delete $(STAGE)

##########################
# Dev targets
# Also see dev folder
##########################

# Lint the commits that have been made to ensure they are conventional commits
.PHONY: commit-lint
commit-lint:
	docker pull --quiet $(COMMIT_LINT_DOCKER_IMAGE)
	$(COMMIT_LINT)

# Deploy the system ready for the end2end tests
.PHONY: e2e-deploy
e2e-deploy:
	make $(MAKE_E2E_ARGS) -C . infra
	make $(MAKE_E2E_ARGS) -C . deploy

.PHONY: e2e-dev
e2e-dev:
	make -C e2e test USER_POOL_ID=$(shell $(DEV_DEPLOY_SH) -c 'terraform output user_pool_id') COGNITO_HOST=$(shell $(DEV_DEPLOY_SH) -c 'terraform output cognito_host') CLIENT_ID=$(shell $(DEV_DEPLOY_SH) -c 'terraform output user_pool_client_id')

.PHONY: e2e-dev-ci
e2e-dev-ci:
	make -C e2e test-ci USER_POOL_ID=$(shell $(DEV_DEPLOY_SH) -c 'terraform output user_pool_id') COGNITO_HOST=$(shell $(DEV_DEPLOY_SH) -c 'terraform output cognito_host') CLIENT_ID=$(shell $(DEV_DEPLOY_SH) -c 'terraform output user_pool_client_id')

# Remove all the resources created by deploying the system for e2e tests
# As an optimisation, don't destroy the main infrastructure as it takes too long to provision
.PHONY: e2e-destroy
e2e-destroy:
	make $(MAKE_E2E_ARGS) -C . destroy-client
	make $(MAKE_E2E_ARGS) -C . destroy-services

.PHONY: destroy-client
destroy-client:
	make S3_BUCKET_ID=$(shell $(S3_BUCKET_ID)) -C $(CLIENT_DIR) app-destroy

.PHONY: destroy-services
destroy-services:
	make -C $(SERVICES_DIR) destroy

# Deploy the infrastructure
.PHONY: infra
infra: infra-build .terraform-plan
	@$(TERRAFORM) apply -auto-approve -input=false .terraform-plan

# sh into the container - useful for running commands like import
.PHONY: infra-sh
infra-sh:
	@$(TERRAFORM_SH)

# Log any of the statics at the top of this file (e.g. make log-DOMAIN)
.PHONY: log-%
log-%:
	@echo $($*)

.PHONY: log-COGNITO_HOST
log-COGNITO_HOST:
	@echo $(shell $(COGNITO_HOST))

.PHONY: log-CLIENT_ID
log-CLIENT_ID:
	@echo $(shell $(CLIENT_ID))

.PHONY: log-TOKEN_ISSUER
log-TOKEN_ISSUER:
	@echo $(shell $(TOKEN_ISSUER))

.PHONY: log-AUTH_DEMO_TABLE_NAME
log-AUTH_DEMO_TABLE_NAME:
	@echo $(shell $(AUTH_DEMO_TABLE_NAME))

.PHONY: log-S3_BUCKET_ID
log-S3_BUCKET_ID:
	@echo $(shell $(S3_BUCKET_ID))

.PHONY: log-AUTH_DEMO_API_URL
log-AUTH_DEMO_API_URL:
	@echo $(shell $(AUTH_DEMO_API_URL))

.PHONY: log-CLIENT_APP_DOMAIN_NAME
log-CLIENT_APP_DOMAIN_NAME:
	@echo $(shell $(CLIENT_APP_DOMAIN_NAME))

.PHONY: clean
clean: terraform-clean;

##########################
# Internal targets
##########################

.PHONY: services-unit
services-unit:
	make -C $(SERVICES_DIR) unit

.PHONY: services-integration
services-integration:
	make -C $(SERVICES_DIR) integration

# Build anything required for the infrastructure
.PHONY: infra-build
infra-build:
	make -C $(CLIENT_DIR) infra-build

.PHONY: .terraform-plan # Always init again as we could have changed environment variables
.terraform: 
	@$(TERRAFORM) init

.PHONY: .terraform-plan # Always re-create the plan
.terraform-plan: .terraform
	@$(TERRAFORM_SH) -c 'terraform workspace new $(STAGE) || exit 0'
	@$(TERRAFORM) workspace select $(STAGE)
	@$(TERRAFORM) plan $(TERRAFORM_VARS) -out $@

# We remove the headers lambda@edge as workaround for https://github.com/terraform-providers/terraform-provider-aws/issues/1721
.PHONY: .terraform-plan-destroy # Always re-create the plan
.terraform-plan-destroy: .terraform
	@$(TERRAFORM) workspace select $(STAGE)
	@$(TERRAFORM) state rm module.client.module.headers.aws_lambda_function.headers
	@$(TERRAFORM) plan -destroy $(TERRAFORM_VARS) -out $@

.PHONY: terraform-clean
terraform-clean:
	$(ALPINE) rm -rf .terraform .terraform-plan .terraform-plan-destroy

.PHONY: services-deploy
services-deploy:
	make USERS_TABLE=$(shell $(AUTH_DEMO_TABLE_NAME)) USER_STORE_API_SECURED_ISSUER=$(shell $(TOKEN_ISSUER)) USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN=https://$(shell $(CLIENT_APP_DOMAIN_NAME)) -C $(SERVICES_DIR) deploy

# Build the e2e tests.
.PHONY: e2e-build
e2e-build: e2e-pull
	$(E2E) build e2e

.PHONY: e2e-pull
e2e-pull:
	$(E2E) pull --quiet

.PHONY: e2e-lighthouse-pull
e2e-lighthouse-pull:
	$(E2E_LIGHTHOUSE) pull --quiet

.PHONY: e2e-observatory-pull
e2e-observatory-pull:
	$(E2E_OBSERVATORY) pull --quiet