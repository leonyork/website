FROM leonyork/awscli:1.18.89-alpine3.12.0

COPY deploy.sh /sbin/deploy
RUN chmod +x /sbin/deploy

ENTRYPOINT [ "deploy" ]