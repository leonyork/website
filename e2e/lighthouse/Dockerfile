# https://hub.docker.com/r/cypress/included
FROM cypress/included:4.9.0
RUN npm install -g wait-on@3.3.x

WORKDIR /app
RUN npm install -g lighthouse-ci@1.10.x

COPY cmd.sh .
RUN chmod +x cmd.sh

ENTRYPOINT []
CMD [ "./cmd.sh" ]