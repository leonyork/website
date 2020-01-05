DOCKER_COMPOSE_DEV=docker-compose -f dev.docker-compose.yml
DEV=$(DOCKER_COMPOSE_DEV) -p leonyork-com-dev

DOCKER_COMPOSE_E2E=docker-compose -f e2e.docker-compose.yml
E2E=$(DOCKER_COMPOSE_E2E) -p leonyork-com-e2e

DOCKER_COMPOSE_E2E_LIGHTHOUSE=docker-compose -f e2e-lighthouse.docker-compose.yml
E2E_LIGHTHOUSE=$(DOCKER_COMPOSE_E2E_LIGHTHOUSE) -p leonyork-com-e2e-lighthouse

DOCKER_COMPOSE_DEPLOY=docker-compose -f deploy.docker-compose.yml
DEPLOY_PROJECT_NAME=leonyork-com-deploy
# Argument for -p and PROJECT_NAME environment variable must be the same for deploy to work
DEPLOY=$(DOCKER_COMPOSE_DEPLOY) -p $(DEPLOY_PROJECT_NAME)
DEPLOY_RUN=$(DEPLOY) run -e "PROJECT_NAME=$(DEPLOY_PROJECT_NAME)"

SERVICE_AUTH_DEMO_API=services/auth-demo/api

# Run the full build
.PHONY: build
build:
	docker-compose build

# Run the application as it would run in prod
.PHONY: prod
prod: build
	docker-compose up

.PHONY: dev-pull
dev-pull:
	$(DEV) pull --quiet

# Build the dev container.
.PHONY: dev-build
dev-build: dev-pull
	$(DEV) build

# Remove node_modules
.PHONY: dev-clear
dev-clear:
	$(DEV) down -v

# Command used to create the project initially. Creates a new project and moves it into the current directory
.PHONY: init
init: dev-build dev-clear
	$(DEV) run --rm dev /bin/sh -c \
		"echo project name: && \
		read PROJECT_NAME && \
		yarn create next-app \$$PROJECT_NAME && \
		echo moving node modules, this could take a while && \
		mv -f \$$PROJECT_NAME/node_modules/* \$$PROJECT_NAME/node_modules/.[!.]* ./node_modules/ && \
		cat README.md >> \$$PROJECT_NAME/README.md && \
		cp -rdf \$$PROJECT_NAME/* \$$PROJECT_NAME/.[!.]* . && \
		rm -rf \$$PROJECT_NAME"

# Run the project in development mode - i.e. hot reloading as you change the code.
.PHONY: dev
dev: dev-build
	$(DEV) up

# sh into the dev container - useful for debugging or installing new dependencies (you should do this inside the container rather than on the host)
.PHONY: dev
dev-sh: dev-build
	$(DEV) run --rm dev /bin/sh

.PHONY: unit
unit:
	make -C $(SERVICE_AUTH_DEMO_API) unit

.PHONY: integration
integration:
	make -C $(SERVICE_AUTH_DEMO_API) integration

.PHONY: e2e-pull
e2e-pull:
	$(E2E) pull --quiet

# Build the e2e tests.
.PHONY: e2e-build
e2e-build: e2e-pull
	$(E2E) build e2e

.PHONY: e2e
e2e: e2e-build
	$(E2E) up --force-recreate --abort-on-container-exit --exit-code-from e2e

.PHONY: e2e-lighthouse-pull
e2e-lighthouse-pull:
	$(E2E_LIGHTHOUSE) pull --quiet

# Build the e2e lighthouse tests. 
.PHONY: e2e-lighthouse-build
e2e-lighthouse-build: e2e-lighthouse-pull
	$(E2E_LIGHTHOUSE) build e2e

.PHONY: e2e-lighthouse
e2e-lighthouse: e2e-lighthouse-build
	$(E2E_LIGHTHOUSE) up --force-recreate --abort-on-container-exit --exit-code-from e2e

.PHONY: test
test: unit integration e2e e2e-lighthouse

.PHONY: deploy-pull
deploy-pull:  
	$(DEPLOY) pull --quiet

.PHONY: deploy-build
deploy-build: deploy-pull
	$(DEPLOY) build deploy

# Deploy to AWS
.PHONY: deploy
deploy: deploy-build
	$(DEPLOY_RUN) deploy

# Remove all the resources created by deploying
.PHONY: destroy
destroy:
	$(DEPLOY_RUN) deploy destroy -auto-approve -input=false -force

# Validate the terraform files required for the deployment
.PHONY: deploy-validate
deploy-validate: deploy-build
	$(DEPLOY_RUN) --entrypoint /bin/sh deploy -c 'terraform init -input=false -backend=false && terraform validate' 

# sh into the container - useful for running commands like import
.PHONY: deploy-sh
deploy-sh: deploy-build
	$(DEPLOY_RUN) --entrypoint /bin/sh deploy