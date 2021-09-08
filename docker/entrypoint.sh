#!/bin/bash -e

export AWS_DEFAULT_REGION=us-east-1
export SERVICE_NAME=hubzone-api

function check_param() {
  if [ -z "${!1}" ]; then
    echo "FATAL ERROR, CONTAINER WILL EXIT:  missing required Environment Variable '$1'"
    MISSING_PARAM=1
  fi
}
function wait_for {
  echo -n "Checking network connectivity for: ${1}:${2}..."
  while ! nc -w5 -z "${1}" "${2}"; do
    echo -n "."
    sleep 1
  done
  echo " Connected."
}

MISSING_PARAM=0
check_param SECRET_KEY_BASE
check_param HUBZONE_API_DB_HOST
check_param HUBZONE_API_DB_USER
check_param HUBZONE_API_DB_NAME
check_param HUBZONE_API_DB_PASSWORD
check_param HUBZONE_GOOGLE_API_KEY
if [ "$MISSING_PARAM" == "1" ]; then exit 1; fi

exec "$@"
