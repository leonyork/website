# Default for testing locally
export REDIRECT_URL=http://localhost:3000/auth-demo

# Run the tests in the cypress GUI
.PHONY: test
test: node_modules
	npm test

# Install modules
node_modules: package.json package-lock.json
	npm install