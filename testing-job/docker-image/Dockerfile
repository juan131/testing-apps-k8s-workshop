FROM bitnami/node:8

# Install required system packages
RUN install_packages procps

# Install PhantomJS
RUN cd /tmp && \
    wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 && \
    tar -xjf phantomjs-1.9.8-linux-x86_64.tar.bz2 && \
    rm -rf phantomjs-1.9.8-linux-x86_64.tar.bz2 && \
    mv phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/bin/

COPY test /test
WORKDIR /test

# Install required npm modules
RUN npm install

CMD ["bash",  "test.sh"]
