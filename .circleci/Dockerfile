FROM mdillon/postgis:9.6 as postgis
RUN apt-get update && apt-get install -qq -y wget --fix-missing --no-install-recommends
RUN echo deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main > /etc/apt/sources.list.d/posgres.list
RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y postgresql-9.6 postgresql-9.6-postgis-2.4 postgresql-contrib-9.6 postgresql-9.6-postgis-2.4-scripts --fix-missing --no-install-recommends

FROM ruby:2.3.3-slim

RUN echo deb http://ftp.debian.org/debian jessie-backports main > /etc/apt/sources.list.d/jessie-backports.list

ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES build-essential libpq-dev netcat git curl software-properties-common apt-utils wget python3 python-pip python-dev
ENV BACKPORT_PACKAGES postgresql-client-9.6

RUN apt-get update && apt-get install -qq -y $PACKAGES --fix-missing --no-install-recommends
RUN apt-get -t jessie-backports install -qq -y $BACKPORT_PACKAGES --fix-missing --no-install-recommends
RUN gem install bundler

RUN pip install -U pip
RUN pip install poirot

COPY --from='postgis' /usr/share/postgresql/9.6/extension /usr/share/postgresql/9.6/extension
