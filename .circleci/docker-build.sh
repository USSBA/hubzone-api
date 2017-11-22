#!/bin/bash -e
if [[ -z "$1" || -z $(echo $1 | cut -s -d. -f1) || -z $(echo $1 | cut -s -d. -f2) || -z $(echo $1 | cut -s -d. -f3) ]]; then
  echo "Please set the VERSION environment variable to the semantic version 'x.y.z' this should be tagged with"
  exit 1
fi
VERSION_MAJOR=$(echo $1 | cut -s -d. -f1)
VERSION_MINOR=$(echo $1 | cut -s -d. -f2)
VERSION_PATCH=$(echo $1 | cut -s -d. -f3)

docker build . -t cc-sba-hz-api
docker tag cc-sba-hz-api sbagov/cc-sba-hz-api:${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
docker tag cc-sba-hz-api sbagov/cc-sba-hz-api:${VERSION_MAJOR}.${VERSION_MINOR}
docker tag cc-sba-hz-api sbagov/cc-sba-hz-api:${VERSION_MAJOR}
docker push sbagov/cc-sba-hz-api:${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
docker push sbagov/cc-sba-hz-api:${VERSION_MAJOR}.${VERSION_MINOR}
docker push sbagov/cc-sba-hz-api:${VERSION_MAJOR}
