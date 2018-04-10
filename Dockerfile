FROM ruby:2.4.3-slim

# Install general packages
ENV PACKAGES build-essential libpq-dev netcat git python3 python-pip python-dev apt-utils wget unzip lftp ssh jq
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Installing packages: ${PACKAGES}..." && apt-get install -y $PACKAGES --fix-missing --no-install-recommends > /dev/null && \
    echo "Done" && rm -rf /var/lib/apt/lists/*

# Install aws-cli
RUN echo "Fetching awscli installer..." && wget -qO "awscli-bundle.zip" "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" && \
    echo "Unpacking..." && unzip awscli-bundle.zip > /dev/null && \
    echo "Installing awscli..." && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws > /dev/null && \
    echo "Done" && rm -rf awscli-bundle awscli-bundle.zip

# Configure/Install Postgres Repos/Deps
ENV PG_PACKAGES postgresql-9.6 postgresql-9.6-postgis-2.4
RUN echo deb http://apt.postgresql.org/pub/repos/apt jessie-pgdg main > /etc/apt/sources.list.d/jessie-pgdg.list && \
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Installing posgres packages: ${PG_PACKAGES}..." && apt-get -t jessie-pgdg install -y $PG_PACKAGES --fix-missing --no-install-recommends > /dev/null && \
    echo "Done." && rm -rf /var/lib/apt/lists/*

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN mkdir -p tmp/pids

# Cache the bundle install
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --quiet

COPY . .

# Setup Entrypoint
RUN cp ./docker/docker-entrypoint-*.sh ./docker/migrate-run.sh /usr/bin/ && chmod 555 /usr/bin/docker-entrypoint-*.sh && chmod 555 /usr/bin/migrate-run.sh
ENTRYPOINT ["docker-entrypoint-aws.sh"]
CMD ["migrate-run.sh"]

ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3001
