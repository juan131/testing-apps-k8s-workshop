FROM bitnami/node:8

# Install required system packages
RUN install_packages procps

COPY test /test
WORKDIR /test

# Install required npm modules
RUN npm install

CMD ["bash",  "test.sh"]
