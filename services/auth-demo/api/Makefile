# Build the dev container
.dev-build:
	docker-compose -f dev.docker-compose.yml build

# Run the project in development mode - i.e. hot reloading as you change the code.
.dev: .dev-build
	docker-compose -f dev.docker-compose.yml up

# Bring down all services
.dev-down:
	docker-compose -f dev.docker-compose.yml down

.task-build:
	docker-compose -f tasks.docker-compose.yml build task

.unit: .task-build
	docker-compose -f tasks.docker-compose.yml run task sh -c 'apk add openssl && npm run unit'

.deploy-build:
	docker-compose -f deploy.docker-compose.yml build

# Deploy to AWS
.deploy: .deploy-build
	docker-compose -f deploy.docker-compose.yml run deploy

# sh into the container - useful for running commands like import
.deploy-sh:  
	docker-compose -f deploy.docker-compose.yml run --entrypoint /bin/sh deploy
