FROM leonyork/awscli:1.17.13-alpine3.11.3

COPY deploy.sh /sbin/deploy
RUN chmod +x /sbin/deploy

ENTRYPOINT [ "deploy" ]