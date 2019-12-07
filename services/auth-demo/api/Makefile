# Build the dev container
.dev-build:
	docker-compose -f dev.docker-compose.yml build

# Run the project in development mode - i.e. hot reloading as you change the code.
.dev: .dev-build
	docker-compose -f dev.docker-compose.yml up

# Sh into the development container
.dev-sh: .dev-build
	docker-compose -f dev.docker-compose.yml run auth-demo-api-dev sh

.task-build:
	docker-compose -f tasks.docker-compose.yml build task

.unit: .task-build
	docker-compose -f tasks.docker-compose.yml run task sh -c "apk add openssl && npm run unit"

.integration-build:
	docker-compose -f integration.docker-compose.yml build

.integration: .integration-build
	docker-compose -f integration.docker-compose.yml up --force-recreate --abort-on-container-exit --exit-code-from users-integration-tests

.deploy-build:
	docker-compose -f deploy.docker-compose.yml build

# Deploy to AWS
.deploy: .deploy-build
	docker-compose -f deploy.docker-compose.yml run deploy

# sh into the container - useful for running commands like import
.deploy-sh:  
	docker-compose -f deploy.docker-compose.yml run --entrypoint /bin/sh deploy
