FROM cypress/included:3.7.0 AS cypress
WORKDIR /app
# See https://github.com/cypress-io/cypress/issues/1243
ENV CI=1
RUN npm install -g wait-on@3.3.0

FROM cypress AS install
COPY package.json package-lock.json ./
RUN npm install && npx cypress verify

FROM install
COPY . .