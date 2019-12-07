# Build the dev container
.dev-build:
	docker-compose -f dev.docker-compose.yml build

# Remove node_modules
.dev-clear:
	docker-compose -f dev.docker-compose.yml down -v

# Command used to create the project initially. Creates a new project and moves it into the current directory
.init: .dev-build .dev-clear
	docker-compose -f dev.docker-compose.yml run --rm dev /bin/sh -c \
		"echo project name: && \
		read PROJECT_NAME && \
		yarn create next-app \$$PROJECT_NAME && \
		echo moving node modules, this could take a while && \
		mv -f \$$PROJECT_NAME/node_modules/* \$$PROJECT_NAME/node_modules/.[!.]* ./node_modules/ && \
		cat README.md >> \$$PROJECT_NAME/README.md && \
		cp -rdf \$$PROJECT_NAME/* \$$PROJECT_NAME/.[!.]* . && \
		rm -rf \$$PROJECT_NAME"

# Run the project in development mode - i.e. hot reloading as you change the code.
.dev: .dev-build
	docker-compose -f dev.docker-compose.yml up

# sh into the dev container - useful for debugging or installing new dependencies (you should do this inside the container rather than on the host)
.dev-sh: .dev-build
	docker-compose -f dev.docker-compose.yml run --rm dev /bin/sh

.unit:
	make -C services/auth-demo/api .unit

.integration:
	make -C services/auth-demo/api .integration

.test: .unit .integration

.deploy-build:  
	docker-compose -f deploy.docker-compose.yml -p leonyork-com-build build deploy

# Deploy to AWS
.deploy:
	PROJECT_NAME=leonyork-com-build docker-compose -f deploy.docker-compose.yml -p leonyork-com-build run deploy

# Remove all the resources created by deploying
.destroy:
	docker-compose -f deploy.docker-compose.yml run deploy destroy -auto-approve -input=false -force

# sh into the container - useful for running commands like import
.deploy-sh:  
	docker-compose -f deploy.docker-compose.yml -p leonyork-com-build run --entrypoint /bin/sh deploy


# Run the full build
build:
	docker-compose build

# Run the application as it would run in prod
.prod: build
	docker-compose up