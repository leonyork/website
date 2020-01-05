DOCKER_COMPOSE_DEV=docker-compose -f dev.docker-compose.yml
DEV=$(DOCKER_COMPOSE_DEV) -p leonyork-com-auth-demo-api-dev

DOCKER_COMPOSE_TASK=docker-compose -f tasks.docker-compose.yml
TASK=$(DOCKER_COMPOSE_TASK) -p leonyork-com-auth-demo-api-task

DOCKER_COMPOSE_INTEGRATION=docker-compose -f integration.docker-compose.yml
INTEGRATION=$(DOCKER_COMPOSE_INTEGRATION) -p leonyork-com-auth-demo-api-integration

DOCKER_COMPOSE_DEPLOY=docker-compose -f deploy.docker-compose.yml
DEPLOY= $(DOCKER_COMPOSE_DEPLOY) -p leonyork-com-auth-demo-api-deploy

.PHONY: dev-pull
dev-pull:
	$(DEV) pull --quiet

# Build the dev container.
.PHONY: dev-build
dev-build: dev-pull
	$(DEV) build

# Run the project in development mode - i.e. hot reloading as you change the code.
.PHONY: dev
dev: dev-build
	$(DEV) up

# Sh into the development container
.PHONY: dev-sh
dev-sh: dev-build
	$(DEV) run auth-demo-api-dev sh

.PHONY: task-pull
task-pull:
	$(TASK) pull --quiet

.PHONY: task-build
task-build: task-pull
	$(TASK) build task

# Run the unit tests
.PHONY: unit
unit: task-build
	$(TASK) run task sh -c "apk add openssl && npm run unit"

.PHONY: integration-pull
integration-pull:
	$(INTEGRATION) pull --quiet

.PHONY: integration-build
integration-build: integration-pull
	$(INTEGRATION) build users-integration-tests

.PHONY: integration
integration: integration-build
	$(INTEGRATION) up --force-recreate --abort-on-container-exit --exit-code-from users-integration-tests

.PHONY: deploy-pull
deploy-pull:
	$(DEPLOY) pull --quiet

.PHONY: deploy-build
deploy-build: deploy-pull
	$(DEPLOY) build

# Deploy to AWS
.PHONY: deploy
deploy: deploy-build
	$(DEPLOY) run deploy

# sh into the container - useful for running commands like import
.PHONY: deploy-sh
deploy-sh:  
	$(DEPLOY) run --entrypoint /bin/sh deploy
