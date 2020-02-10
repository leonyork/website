DOCKER_COMPOSE_PROJECT=website-client-app

BUILD=docker-compose -f build.docker-compose.yml -p $(DOCKER_COMPOSE_PROJECT)
BUILD_SERVICE=client-app-build

DEPLOY=docker-compose -f deploy.docker-compose.yml -p $(DOCKER_COMPOSE_PROJECT)
DEPLOY_SERVICE=client-app-deploy

#############################
# External targets
#############################

# Deploy the client app
.PHONY: deploy
deploy: docker-deployer-build out
	$(DEPLOY) run $(DEPLOY_SERVICE)

#############################
# Test commands
#############################

# Synonym for building the client app
.PHONY: build
build: out;

#############################
# Internal targets
#############################

# Build the client app
out: docker-builder-build cms components content images pages public .dockerignore next.config.js package.json yarn.lock
	$(BUILD) run $(BUILD_SERVICE)

# Build the builder image
.PHONY: docker-builder-build
docker-builder-build: 
	$(BUILD) build

# Build the deployer image
.PHONY: docker-deployer-build
docker-deployer-build:
	$(DEPLOY) build

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