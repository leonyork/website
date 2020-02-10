AUTH_DEMO_DIR=auth-demo

##########################
# External targets
##########################

# Run unit tests
.PHONY: unit
unit: auth-demo-unit;

# Run integration tests
.PHONY: integration
integration: auth-demo-integration;

# Need to run the deployment of the services before the app deployment (so that we can get URLs of the services to call)
.PHONY: deploy
deploy:
	make -C $(AUTH_DEMO_DIR) api-deploy

# Only need to destroy the services as the front end will be taken care of by destroying the infrastructure
.PHONY: destroy
destroy:
	make -C $(AUTH_DEMO_DIR) api-destroy

##########################
# Internal targets
##########################

.PHONY: auth-demo-unit
auth-demo-unit:
	make -C $(AUTH_DEMO_DIR) unit

.PHONY: auth-demo-integration
auth-demo-integration:
	make -C $(AUTH_DEMO_DIR) integration