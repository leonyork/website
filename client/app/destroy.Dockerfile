FROM leonyork/awscli:1.18.39-alpine3.11.5

COPY destroy.sh /sbin/destroy
RUN chmod +x /sbin/destroy

ENTRYPOINT [ "destroy" ]