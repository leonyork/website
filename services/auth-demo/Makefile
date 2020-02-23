API_DIR=api

##########################
# External targets
##########################

# Run the unit tests
.PHONY: unit
unit: api-unit;

# Run the integration tests
.PHONY: integration
integration: api-integration;

# Build things required for deployment
.PHONY: build
build: api-build;

# Deploy to AWS
.PHONY: deploy
deploy: api-deploy;

# Destroy the services
.PHONY: destroy
destroy: api-destroy;

##########################
# Internal targets
##########################

.PHONY: api-unit
api-unit:
	make -C $(API_DIR) unit

.PHONY: api-integration
api-integration: 
	make -C $(API_DIR) integration

.PHONY: api-build
api-build: 
	make -C $(API_DIR) build

.PHONY: api-deploy
api-deploy: 
	make -C $(API_DIR) deploy

.PHONY: api-destroy
api-destroy: 
	make -C $(API_DIR) destroy