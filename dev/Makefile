RELATIVE_DIR_DEV=./

DOCKER_COMPOSE_DEV=docker-compose -f $(RELATIVE_DIR_DEV)docker-compose.yml
DOCKER_COMPOSE_DEV_DEPLOY=docker-compose -f $(RELATIVE_DIR_DEV)docker-compose-deploy.yml

DOCKER_COMPOSE_DEV_INSTALL=$(DOCKER_COMPOSE_DEV) -f $(RELATIVE_DIR_DEV)docker-compose-install.yml
DOCKER_COMPOSE_DEV_CLEAN=$(DOCKER_COMPOSE_DEV_INSTALL) -f $(RELATIVE_DIR_DEV)docker-compose-clean.yml

DOCKER_COMPOSE_DEV_DESTROY=$(DOCKER_COMPOSE_DEV_DEPLOY) -f $(RELATIVE_DIR_DEV)docker-compose-destroy.yml

DEV_PROJECT_NAME=leonyork-com-dev

DEV=$(DOCKER_COMPOSE_DEV) -p $(DEV_PROJECT_NAME)
DEV_DEPLOY=$(DOCKER_COMPOSE_DEV_DEPLOY) -p $(DEV_PROJECT_NAME)
DEV_INSTALL=$(DOCKER_COMPOSE_DEV_INSTALL) -p $(DEV_PROJECT_NAME)
DEV_CLEAN=$(DOCKER_COMPOSE_DEV_CLEAN) -p $(DEV_PROJECT_NAME)
DEV_DESTROY=$(DOCKER_COMPOSE_DEV_DESTROY) -p $(DEV_PROJECT_NAME)

DEV_DEPLOY_SH=$(DEV_DEPLOY) run auth-demo-cognito-dev

# Run the project in development mode - i.e. hot reloading as you change the code.
.PHONY: dev
dev: export DEV_COGNITO_HOST=$(shell $(DEV_DEPLOY_SH) -c 'terraform output cognito_host')
dev: export DEV_TOKEN_ISSUER=$(shell $(DEV_DEPLOY_SH) -c 'terraform output token_issuer')
dev: export DEV_USER_POOL_CLIENT_ID=$(shell $(DEV_DEPLOY_SH) -c 'terraform output user_pool_client_id')
dev: dev-deploy dev-install
	$(DEV) up --abort-on-container-exit --remove-orphans

.PHONY: dev-clean
dev-clean:
	$(DEV_DESTROY) up --remove-orphans
	$(DEV_CLEAN) up --remove-orphans
	$(DEV) down -v

.PHONY: dev-pull
dev-pull:
	$(DEV) pull --quiet

# Build the dev container.
.PHONY: dev-build
dev-build: dev-pull
	$(DEV) build

.PHONY: dev-install
dev-install: dev-build
	$(DEV_INSTALL) up --remove-orphans

.PHONY: dev-deploy
dev-deploy:
	$(DEV_DEPLOY) up --remove-orphans

.PHONY: dev-destroy
dev-destroy:
	$(DEV_DESTROY) up --remove-orphans
