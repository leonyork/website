ARG NODE_VERSION
FROM amazon/dynamodb-local:1.11.477 AS install

USER root
RUN yum -y install awscli

USER dynamodblocal

ENV AWS_SECRET_KEY_ID=dummy
ENV AWS_ACCESS_KEY_ID=dummy
ENV AWS_SECRET_ACCESS_KEY=dummy
ARG TABLE_NAME=auth-demo-users-dev

RUN mkdir ~/db && \
    java -jar DynamoDBLocal.jar -sharedDb -dbPath ~/db & \
    DYNAMO_PID=$! && \
    aws dynamodb create-table --table-name ${TABLE_NAME} --attribute-definitions AttributeName=id,AttributeType=S \
        --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --endpoint-url http://localhost:8000 --region us-east-1 && \
    kill $DYNAMO_PID

RUN ls ~/db

FROM amazon/dynamodb-local:1.11.477

COPY --chown=dynamodblocal:dynamodblocal --from=install /home/dynamodblocal/db /home/dynamodblocal/db

CMD ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "/home/dynamodblocal/db"]