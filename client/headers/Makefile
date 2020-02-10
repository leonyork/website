export STAGE=dev
export REGION=us-east-1

DOCKER_COMPOSE_DEV=docker-compose -f dev.docker-compose.yml
DEV=$(DOCKER_COMPOSE_DEV) -p leonyork-com-auth-demo-api-dev

# Package the zip for deployment
.PHONY: package
package: .serverless/headers.zip;

# Sh into the development container
.PHONY: dev-sh
dev-sh: dev-build
	$(DEV) run headers-dev sh

# Package the zip for deployment
.serverless/headers.zip: src/handlers/origin-response.js package.json package-lock.json serverless.yml webpack.config.js
	$(DEV) run headers-dev npm run package -- --stage=$(STAGE) --region=$(REGION)

# Build the dev container.
.PHONY: dev-build
dev-build: dev-pull
	$(DEV) build

.PHONY: dev-pull
dev-pull:
	$(DEV) pull --quiet