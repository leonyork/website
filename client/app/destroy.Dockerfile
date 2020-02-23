FROM leonyork/awscli:1.17.13-alpine3.11.3

COPY destroy.sh /sbin/destroy
RUN chmod +x /sbin/destroy

ENTRYPOINT [ "destroy" ]