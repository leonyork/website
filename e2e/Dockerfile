FROM cypress/included:3.8.0 AS cypress
RUN npm install -g wait-on@3.3.x

WORKDIR /app

FROM cypress AS install
COPY package.json package-lock.json ./
RUN npm install && npx cypress verify

FROM install
COPY . .