FROM cypress/included:3.8.0 AS cypress
WORKDIR /app
RUN npm install -g wait-on@3.3.0

FROM cypress AS install
COPY package.json package-lock.json ./
RUN npm install && npx cypress verify

FROM install
COPY . .