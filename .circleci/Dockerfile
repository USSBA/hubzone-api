# FROM mdillon/postgis:9.6 as postgis
FROM ruby:2.3.3-slim

# Install general packages
ENV PACKAGES build-essential libpq-dev netcat git curl apt-utils wget python3 python-pip python-dev software-properties-common
RUN apt-get -qq update && \
    apt-get -qq install -y $PACKAGES --fix-missing --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Configure/Install Postgres Repos/Deps
ENV PG_PACKAGES postgresql-9.6 postgresql-9.6-postgis-2.4
RUN echo deb http://apt.postgresql.org/pub/repos/apt jessie-pgdg main > /etc/apt/sources.list.d/jessie-pgdg.list && \
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
RUN apt-get -qq update && \
    apt-get -qq -t jessie-pgdg install -y $PG_PACKAGES --fix-missing --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler

RUN pip install -U pip
RUN pip install poirot
