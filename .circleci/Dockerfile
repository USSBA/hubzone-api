FROM mdillon/postgis:9.6 as postgis
# RUN apt-get update && apt-get install -qq -y wget --fix-missing --no-install-recommends
# RUN echo deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main > /etc/apt/sources.list.d/posgres.list
# RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

# RUN apt-get update && apt-get install -y postgresql-9.6 postgresql-9.6-postgis-2.4 postgresql-contrib-9.6 postgresql-9.6-postgis-2.4-scripts --fix-missing --no-install-recommends

RUN echo deb http://ftp.debian.org/debian jessie-backports main > /etc/apt/sources.list.d/jessie-backports.list

ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES build-essential libpq-dev netcat git curl software-properties-common apt-utils wget python3 python-pip python-dev
ENV BACKPORT_PACKAGES postgresql-client-9.6

RUN apt-get update && apt-get install -qq -y $PACKAGES --fix-missing --no-install-recommends
RUN apt-get -t jessie-backports install -qq -y $BACKPORT_PACKAGES --fix-missing --no-install-recommends

RUN pip install -U pip
RUN pip install poirot

# RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# RUN curl -sSL https://get.rvm.io | bash -s stable --ruby
# RUN rvm install ruby-2.3.3
# RUN ruby -v
