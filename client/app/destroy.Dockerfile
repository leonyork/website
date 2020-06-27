FROM leonyork/awscli:1.18.89-alpine3.12.0

COPY destroy.sh /sbin/destroy
RUN chmod +x /sbin/destroy

ENTRYPOINT [ "destroy" ]