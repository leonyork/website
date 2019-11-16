ARG TERRAFORM_VERSION
FROM hashicorp/terraform:${TERRAFORM_VERSION}

COPY scripts/install/deploy.sh /install.sh
RUN sh /install.sh && rm -rf /install.sh