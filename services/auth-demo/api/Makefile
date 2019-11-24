.deploy-build:
	docker-compose -f deploy.docker-compose.yml build

# Deploy to AWS
.deploy: .deploy-build
	docker-compose -f deploy.docker-compose.yml run deploy

# sh into the container - useful for running commands like import
.deploy-sh:  
	docker-compose -f deploy.docker-compose.yml run --entrypoint /bin/sh deploy
