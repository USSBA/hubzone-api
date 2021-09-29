FROM ruby:2.5-slim-stretch

# Install general packages
ENV PACKAGES build-essential libpq-dev netcat git apt-utils wget unzip lftp ssh jq gnupg
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Installing packages: ${PACKAGES}..." && apt-get install -y $PACKAGES --fix-missing --no-install-recommends > /dev/null && \
    echo "Done" && rm -rf /var/lib/apt/lists/*

# Configure/Install Postgres Repos/Deps
ENV PG_PACKAGES postgresql-client postgresql-12-postgis-2.5
RUN echo deb http://apt.postgresql.org/pub/repos/apt stretch-pgdg main > /etc/apt/sources.list.d/stretch-pgdg.list && \
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN echo "Updating repos..." && apt-get update > /dev/null && \
    echo "Installing posgres packages: ${PG_PACKAGES}..." && apt-get -t stretch-pgdg install -y $PG_PACKAGES --fix-missing --no-install-recommends > /dev/null && \
    echo "Done." && rm -rf /var/lib/apt/lists/*

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN mkdir -p tmp/pids

# Cache the bundle install
RUN gem install 'bundler:~>2.0'
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --quiet

COPY . .

# Setup Entrypoint
RUN cp ./docker/entrypoint.sh ./docker/start-rails.sh /usr/bin/ && chmod 555 /usr/bin/entrypoint.sh && chmod 555 /usr/bin/start-rails.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["start-rails.sh"]

ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3001
