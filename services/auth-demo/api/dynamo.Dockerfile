ARG DB_LOCATION=/home/dynamodblocal/db
# https://hub.docker.com/r/amazon/dynamodb-local
FROM amazon/dynamodb-local:1.13.1 AS install

USER root
RUN yum -y install awscli

USER dynamodblocal

ENV AWS_ACCESS_KEY_ID=dummy
ENV AWS_SECRET_ACCESS_KEY=dummy
ARG DB_LOCATION
ARG TABLE_NAME=auth-demo-users-dev

RUN mkdir -p ${DB_LOCATION} && \
    java -jar DynamoDBLocal.jar -sharedDb -dbPath ${DB_LOCATION} & \
    DYNAMO_PID=$! && \
    aws dynamodb create-table --table-name ${TABLE_NAME} --attribute-definitions AttributeName=id,AttributeType=S \
        --key-schema AttributeName=id,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --endpoint-url http://localhost:8000 --region us-east-1 && \
    kill $DYNAMO_PID

# https://hub.docker.com/r/amazon/dynamodb-local
FROM amazon/dynamodb-local:1.13.1

ARG DB_LOCATION
COPY --chown=dynamodblocal:dynamodblocal --from=install ${DB_LOCATION} /db

CMD ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "/db"]