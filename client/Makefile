APP_DIR=app
HEADERS_DIR=headers

# Build anything required for the infrastructure
.PHONY: infra-build
infra-build: headers-package;

# Deploy the client app
.PHONY: app-deploy
app-deploy:
	make REACT_APP_USER_API_URL=$(AUTH_DEMO_API_URL) REACT_APP_URL=https://$(DOMAIN) REACT_APP_CLIENT_ID=$(CLIENT_ID) REACT_APP_COGNITO_HOST=https://$(COGNITO_HOST) -C $(APP_DIR) deploy

# Destroy the client app
.PHONY: app-destroy
app-destroy:
	make -C $(APP_DIR) destroy

# Package the headers
.PHONY: headers-package
headers-package: 
	make -C $(HEADERS_DIR) package