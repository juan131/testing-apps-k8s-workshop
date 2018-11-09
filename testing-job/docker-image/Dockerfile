FROM bitnami/node:8

# Install required system packages
RUN install_packages procps

COPY test /test
WORKDIR /test

# Install required npm modules
RUN npm install chai debug http mocha path

CMD ["bash",  "test.sh"]

