FROM leonyork/awscli:1.18.39-alpine3.11.5

COPY deploy.sh /sbin/deploy
RUN chmod +x /sbin/deploy

ENTRYPOINT [ "deploy" ]