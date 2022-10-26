FROM ruby:2.7.4-slim-bullseye

# Install general packages
ENV PACKAGES build-essential libpq-dev netcat git apt-utils wget unzip lftp ssh jq gnupg lsb-release
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Upgrading base packages..." && apt-get upgrade -y > /dev/null && \
    echo "Installing packages: ${PACKAGES}..." && apt-get install -y $PACKAGES --fix-missing --no-install-recommends > /dev/null && \
    echo "Done" && rm -rf /var/lib/apt/lists/*

# Configure/Install Postgres Repos/Deps
ENV PG_PACKAGES postgresql-client-12 postgresql-12-postgis-3
RUN echo deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Installing posgres packages: ${PG_PACKAGES}..." && apt-get install -y $PG_PACKAGES --fix-missing --no-install-recommends > /dev/null && \
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

COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
COPY docker/start-rails.sh /usr/bin/start-rails.sh
RUN chmod +x /usr/bin/entrypoint.sh /usr/bin/start-rails.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/start-rails.sh"]

ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3001
