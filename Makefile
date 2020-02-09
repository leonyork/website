##########################
# Includes
##########################
include dev/Makefile
RELATIVE_DIR_DEV=./dev/

##########################
# Versions
##########################
ALPINE_VERSION=3.11.3

##########################
# Variables
##########################
STAGE_PRODUCTION=production
DOMAIN_PRODUCTION=leonyork.com
MAKE_PRODUCTION_ARGS=STAGE=$(STAGE_PRODUCTION) DOMAIN=$(DOMAIN_PRODUCTION)

STAGE_E2E=e2e
DOMAIN_E2E=
MAKE_E2E_ARGS=STAGE=$(STAGE_E2E) DOMAIN=$(DOMAIN_E2E)

##########################
# Commands
##########################
ALPINE=docker run -v $(CURDIR):/app -w /app alpine:$(ALPINE_VERSION)
USER_NAME=

DOCKER_COMPOSE_E2E=docker-compose -f e2e.docker-compose.yml
E2E=$(DOCKER_COMPOSE_E2E) -p leonyork-com-e2e

DOCKER_COMPOSE_E2E_LIGHTHOUSE=docker-compose -f e2e-lighthouse.docker-compose.yml
E2E_LIGHTHOUSE=$(DOCKER_COMPOSE_E2E_LIGHTHOUSE) -p leonyork-com-e2e-lighthouse

##########################
# Sub-makes
##########################
PACKAGES_DIR=packages

##########################
# External targets
##########################

# Run the unit tests
.PHONY: unit
unit:
	make -C $(PACKAGES_DIR) unit

# Run the integration tests
.PHONY: integration
integration:
	make -C $(PACKAGES_DIR) integration

# Deploy the infrastructure
.PHONY: infra
infra: 
	make $(MAKE_PRODUCTION_ARGS) -C $(PACKAGES_DIR) infra

# Deploy the apps onto the infrastructure
.PHONY: deploy
deploy: 
	make $(MAKE_PRODUCTION_ARGS) -C $(PACKAGES_DIR) deploy

# Run the end2end tests
.PHONY: e2e
e2e: export CYPRESS_baseUrl=https://$(shell make $(MAKE_E2E_ARGS) -C $(PACKAGES_DIR) log-CLIENT_APP_DOMAIN_NAME)
e2e: e2e-build
	$(E2E) up --force-recreate --abort-on-container-exit --exit-code-from e2e

# Run the lighthouse end2end tests
.PHONY: e2e-lighthouse
e2e-lighthouse: export BASE_URL=https://$(shell make $(MAKE_E2E_ARGS) -C $(PACKAGES_DIR) log-CLIENT_APP_DOMAIN_NAME)
e2e-lighthouse: e2e-lighthouse-build
	$(E2E_LIGHTHOUSE) up --force-recreate --abort-on-container-exit --exit-code-from e2e

# Remove all the resources created by deploying
.PHONY: destroy
destroy:
	make $(MAKE_PRODUCTION_ARGS) -C $(PACKAGES_DIR) destroy

##########################
# Dev targets
# Also see dev folder
##########################

# Run the end2end tests
.PHONY: e2e-deploy
e2e-deploy:
	make $(MAKE_E2E_ARGS) -C $(PACKAGES_DIR) infra
	make $(MAKE_E2E_ARGS) -C $(PACKAGES_DIR) deploy

# Remove all the resources created by deploying
.PHONY: e2e-destroy
e2e-destroy:
	make $(MAKE_E2E_ARGS) -C $(PACKAGES_DIR) destroy

# Run the e2e tests against your dev environment using the gui (assumes you have already run make dev and the dev environment is up)
.PHONY: e2e-dev
e2e-dev:
	make -C e2e test COGNITO_HOST=$(DEV_COGNITO_HOST) CLIENT_ID=$(DEV_USER_POOL_CLIENT_ID)

# Validate the terraform files required for the deployment
.PHONY: infra-validate
infra-validate:
	make -C $(PACKAGES_DIR) infra-validate

##########################
# Internal targets
##########################

# Build the e2e tests.
.PHONY: e2e-build
e2e-build: e2e-pull
	$(E2E) build e2e

.PHONY: e2e-pull
e2e-pull:
	$(E2E) pull --quiet

# Build the e2e lighthouse tests. 
.PHONY: e2e-lighthouse-build
e2e-lighthouse-build: e2e-lighthouse-pull
	$(E2E_LIGHTHOUSE) build e2e

.PHONY: e2e-lighthouse-pull
e2e-lighthouse-pull:
	$(E2E_LIGHTHOUSE) pull --quiet