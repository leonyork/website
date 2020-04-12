FROM cypress/included:4.3.0 AS cypress
WORKDIR /app

FROM cypress AS install
COPY package.json package-lock.json ./
RUN npm install && npx cypress verify

FROM install
COPY . .