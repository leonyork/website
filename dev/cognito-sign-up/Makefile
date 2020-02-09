STAGE=dev
REGION=us-east-1

DOCKER_COMPOSE_DEV=docker-compose -f dev.docker-compose.yml
DEV=$(DOCKER_COMPOSE_DEV) -p leonyork-com-cognito-signup-dev

.PHONY: dev-pull
dev-pull:
	$(DEV) pull --quiet

# Build the dev container.
.PHONY: dev-build
dev-build: dev-pull
	$(DEV) build

# Package the zip for deployment
.PHONY: package
package: dev-build
	$(DEV) run cognito-signup-dev npm run package -- --stage=$(STAGE) --region=$(REGION)

# Sh into the development container
.PHONY: dev-sh
dev-sh: dev-build
	$(DEV) run cognito-signup-dev sh