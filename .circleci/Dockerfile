FROM ruby:2.3.3-slim

RUN echo deb http://ftp.debian.org/debian jessie-backports main > /etc/apt/sources.list.d/jessie-backports.list

ENV PACKAGES build-essential libpq-dev netcat git
ENV BACKPORT_PACKAGES postgresql-client-9.6 postgis

RUN apt-get update && apt-get install -qq -y $PACKAGES --fix-missing --no-install-recommends
RUN apt-get -t jessie-backports install -qq -y $BACKPORT_PACKAGES --fix-missing --no-install-recommends
RUN gem install bundler
