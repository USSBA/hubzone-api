#!/bin/bash

# Set hubzone-api defaults here.  These tasks will be run every time the container starts
RAKE_ASSETS_PRECOMPILE=${RAKE_ASSETS_PRECOMPILE:-false}
RAKE_DB_CREATE=${RAKE_DB_CREATE:-true}
RAKE_DB_MIGRATE=${RAKE_DB_MIGRATE:-true}
RAKE_DB_SEED=${RAKE_DB_SEED:-false}

function bundle-exec-rake {
  echo "Starting ${1}..."
  EXECUTION_OUTPUT=$(bundle exec rake ${1} 2>&1)
  EXECUTION_RESPONSE=$?
  if [ "$EXECUTION_RESPONSE" != "0" ]; then
    echo $EXECUTION_OUTPUT | grep -q "another migration process is currently running" > /dev/null
    MIGRATION_RUNNING=$(echo $EXECUTION_OUTPUT | grep -q "another migration process is currently running" > /dev/null; echo $?)
    CREATE_RUNNING=$(echo $EXECUTION_OUTPUT | grep -q "duplicate key value violates unique constraint" > /dev/null; echo $?)
    while [ "$MIGRATION_RUNNING" == "0" ] || [ "$CREATE_RUNNING" == "0" ] ; do
      SLEEP_TIME=$(( ( RANDOM % 10 )  + 1 ))
      echo "WARN: ${1} likely already running.  Sleeping for ${SLEEP_TIME} before retrying"
      sleep ${SLEEP_TIME}
      EXECUTION_OUTPUT=$(bundle exec rake ${1} 2>&1)
      EXECUTION_RESPONSE=$?
      MIGRATION_RUNNING=$(echo $EXECUTION_OUTPUT | grep -q "another migration process is currently running" > /dev/null; echo $?)
      CREATE_RUNNING=$(echo $EXECUTION_OUTPUT | grep -q "duplicate key value violates unique constraint" > /dev/null; echo $?)
    done
    if [ "$EXECUTION_RESPONSE" != "0" ]; then
      echo "${EXECUTION_OUTPUT}"
      echo "FATAL: ${1} failed.  Container will now stop."
      exit 10
    else
      echo "Done ${1}"
    fi
  else
    echo "Done ${1}"
  fi
}

[ "$RAKE_ASSETS_PRECOMPILE" = "true" ] && bundle-exec-rake assets:precompile
[ "$RAKE_DB_CREATE" = "true" ]         && bundle-exec-rake db:create
[ "$RAKE_DB_MIGRATE" = "true" ]        && bundle-exec-rake db:migrate
[ "$RAKE_DB_SEED" = "true" ]           && bundle-exec-rake db:seed

echo "Starting rails server..."
bundle exec rails server -b 0.0.0.0
if [[ $? -eq 0 ]]; then
  echo "Rails server exited without error code, but it probably shouldn't have. Container will now stop."
else
  echo "FATAL: Rails server exited with error code $?.  Container will now stop."
  exit 20
fi
