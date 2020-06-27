# https://hub.docker.com/r/cypress/included
FROM cypress/included:4.9.0 AS cypress
WORKDIR /app

FROM cypress AS install
COPY package.json package-lock.json ./
RUN npm install && npx cypress verify

FROM install
COPY . .