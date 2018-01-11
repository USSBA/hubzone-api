# HUBZone API

This application houses the custom HUBZone Geo API for the Small Business Administration.

### Table of Contents
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Building](#building)
  - [Deploying](#deploying)
- [API Specification](#api-specification)
- [Testing](#testing)
- [External Services](#external-services)
- [Changelog](#changelog)
- [License](#license)
- [Contributing](#contributing)
- [Security Issues](#security-issues)

## Installation
### Requirements:
* RVM
  - http://rvm.io/
* Ruby 2.3.3
  - `rvm install 2.3.3`
* Bundler
  - `rvm @global do gem install bundler`
  - Tested with version 1.13.6 or later
* PostgreSQL 9.5
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
  * Poirot
    - Install [Poirot](https://github.com/emanuelfeld/poirot) python utility, typically `pip install poirot` and make sure that poirot is available in PATH by confirming that your PYTHON/bin folder is in PATH.
    - Refer to [Poirot Secrets Testing](#poirot-secrets-testing) for information on running this tool.
    - For local development, run the rake task to copy the `pre-commit-poirot` script to your local `.git/hooks/pre-commit` hook.
      ```
        rake hz:poirot_hooks
      ```

### Building
After cloning the repo, checkout out the `develop` branch and set up your environment:
```
git checkout develop
cp example.env .env
# edit .env to provide your PostgreSQL user/password and, if necessary, override any defaults
```

Then run the following:
``` bash
bundle install
```

If the `bundle install` fails due to the pg gem, make sure you have the ENV vars above set in your shell.

Note that we run on  port 3001 for local development.  Also, the database is shared between this repo and the hubzone-data-etl repo, with the etl repo creating and populating the database.

### Deploying
To launch the api:
``` bash
rails server
```
*NOTE:* PORT is set by default in `config/puma.rb` to 3001, so it is not necessary to specify a port when running `rails s`

## API Specification
### Search - `GET` /api/search
#### Request Parameters
* `q`
  - The string used for the search. Will be sent to Google Geocoding API to get a specific latitude/longitude
* `latlng`
  - A specific latitude/longitude in string format
* `query_date`
  - The date of the query
Search requests can include either `q` or `latlng`

#### Response
Search requests return a JSON object with the following fields

* `address_components`
  - an array of the address after it has been parsed by Google Geocoding API
* `hubzone`
  - an array the Hubzone status and details
* `place_id`
  - a Google Geocoding API UUID string for this particular location
* `types`
  - an array of the types for this location as determined by the Google Geocoding API
* `http_status`
  - the status of the request to Google Geocoding API
* `other_information`
  - an array of pertinent information about this location including pending disasters and Congressional district
* `status`
  - the http status of the
* `formatted_address`
  - the search string reformatted by the Google Geocoding API
* `geometry`
  - an array defining the bounding box of the search query
* `until_date`
  - a defined expiration date for the results of the search
* `search_q`
  - the `q` parameter used in this request
* `search_latlng`
  - the `latlng` parameter used in this request
* `api_version`
  - the version of the Hubzone API that was used in this request

### Version - `GET` /api/version

Returns the currently deployed version of the Hubzone API as a string

### Health Check - `GET` /api/aws-hc
 Returns the string `"I'm OK"` if the Hubzone API is running

## Tests
### RSpec Tests

A note on tests, test API Assertions (HZ assertion by latlng or by address) are relative to a dummy test database hzgeo_test, that is populated by `spec/helpers/test_data_helper.rb`.  Updates to main data schema need to be mirrored in the SQL in that file.

To run the test suite, simply run:
```
rspec
```

or with verbose output:
```
rspec -f d
```

To view the coverage report, open
```
coverage/index.html
```

### Rubocop
```
rubocop -D
```

#### Poirot Secrets Testing
A secrets pattern file `hubzone-poiroit-patterns.txt` is included with the app to assist with running [Poirot](https://github.com/emanuelfeld/poirot) to scan commit history for secrets.  It is recommended to run this only the current branch only:
```
  poirot --patterns hubzone-poirot-patterns.txt --revlist="develop^..HEAD"
```
Poirot will return an error status if it finds any secrets in the commit history between `HEAD` and develop.  You can correct these by: removing the secrets and squashing commits or by using something like BFG.

Note that Poirot is hardcoded to run in case-insensitive mode and uses two different regex engines (`git log --grep` and a 3rd-party Python regex library https://pypi.python.org/pypi/regex/ ). Refer to Lines 121 and 195 in `<python_path>/site-packages/poirot/poirot.py`. The result is that the 'ssn' matcher will flag on: 'ssn', 'SSN', or 'ssN', etc., which also finds 'className', producing false positive errors in the full rev history.  Initially we included the `(?c)` flag in the SSN matchers: `.*(ssn)(?c).*[:=]\s*[0-9-]{9,11}` however this is not compatible with all regex engines and causes an error in some cases.  During the `--revlist="all"` full history Poirot runs, this pattern failed silently with the `git --grep` engine and therefore did not actually run.  During the `--staged` Poirot runs, this pattern fails with a stack trace with the `pypi/regex` engine. The `(?c)` pattern has been removed entirely and so the `ssn` patterns can still flag on false positives like 'className'.

##### Poirot Git Hooks
A rake task was included to copy a template `pre-commit-poirot` shell script to the local users `.git/hooks/pre-commit` hook.  This will run Poirot using the patterns file mentioned above on any staged files.  The pre-commit script was copied from https://raw.githubusercontent.com/DCgov/poirot/master/pre-commit-poirot.
```
  rake hz:poirot_hooks
```

## External services
- Connect to [Google Map API](https://developers.google.com/maps/) by putting your key in the .env file

## Changelog
Refer to the changelog for details on changes to API. [CHANGELOG](CHANGELOG.md)

## License
HUBZone-API is licensed permissively under the Apache License v2.0.
A copy of that license is distributed with this software.

This project may use Google APIs. The Google API are license under their Google API's [terms and conditions](https://developers.google.com/maps/terms).

## Contributing
We welcome contributions. Please read [CONTRIBUTING](CONTRIBUTING.md) for how to contribute.

We strive for a welcoming and inclusive environment for the HUBZone-API project.

Please follow this guidelines in all interactions:

1. Be Respectful: use welcoming and inclusive language.
2. Assume best intentions: seek to understand other's opinions.

## Security Issues
Please do not submit an issue on GitHub for a security vulnerability. Please contact the development team through the Certify Help Desk at [help@certify.sba.gov](mailto:help@certify.sba.gov).

Be sure to include all the pertinent information.

<sub>The agency reserves the right to change this policy at any time.</sub>
