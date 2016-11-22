# HUBZone API

This application houses the custom HUBZone Geo API for the Small Business Administration.

Requirements:
* rvm
  - http://rvm.io/
* ruby 2.3.1
  - `rvm install 2.3.1`
* JavaScript interpreter (node)
  * nvm
    * `curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash`
  * Install node
    * `nvm install 5`
* bundler 1.12.5
  - `gem install -v 1.12.5 bundler`
* postgresql 9.5
  * Mac
    - I use [Postgres.app](http://postgresapp.com/)
    - could also use `brew install postgresql`
    - set `PGSQL_HOME` to your installation dir
      - e.g. `export PGSQL_HOME=/Applications/Postgres.app/Contents/Versions/9.5`
    - ensure that the bin directory is in your path
      - e.g. `export PATH=${PATH}:${PGSQL_HOME}/bin`
  * Linux (rhel)
    * Install:
      * `yum install https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-6-x86_64/pgdg-redhat95-9.5-3.noarch.rpm`
      * `yum install postgresql95-server postgresql95-devel`
    * Configure:
      * `echo 'export PGSQL_HOME=/usr/pgsql-9.5' >> ~/.bashrc`
      * `echo 'export PATH=${PATH}:${PGSQL_HOME}/bin' >> ~/.bashrc`

After cloning the repo, run the following:
``` bash
cd hubzone_api
bundle install
bundle exec rake db:migrate
rails server -p 3001
```

Note that we run on  port 3001 for local development.  Also, the database is shared between this repo and the hubzone-data-etl repo, with the etl repo creating and populating the database.  Migrations are mainly for test data.

If the `bundle install` fails due to the pg gem, make sure you have the ENV vars above set in your shell.

To run the test suite, simply run:
* `rspec`
* or with verbose output: `rspec -f d`


