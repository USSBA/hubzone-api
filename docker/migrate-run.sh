#!/bin/bash

echo "Starting db:create db:migrate..."
MIGRATION_OUTPUT=$(bundle exec rake db:create db:migrate 2>&1)
MIGRATION_RESPONSE=$?
if [ "$?" != "0" ]; then
  echo $MIGRATION_OUTPUT | grep -q "another migration process is currently running"
  MIGRATION_RUNNING=$?
  while [ "$MIGRATION_RUNNING" == "0" ]; do
    SLEEP_TIME=$(( ( RANDOM % 10 )  + 1 ))
    echo "WARN: Migration already running.  Sleeping for ${SLEEP_TIME} before retrying"
    sleep ${SLEEP_TIME}
    MIGRATION_OUTPUT=$(bundle exec rake db:create db:migrate 2>&1)
    MIGRATION_RESPONSE=$?
    echo $MIGRATION_OUTPUT | grep -q "another migration process is currently running"
    MIGRATION_RUNNING=$?
  done
  if [ "$MIGRATION_RESPONSE" != "0" ]; then
    echo "FATAL: db:migrate failed for reason other than concurrent migration.  Container will now stop. Printing migration output now:"
    echo "${MIGRATION_OUTPUT}"
    exit 10
  fi
fi
echo "Done db:create db:migrate"
echo "Starting rails server..."
bundle exec rails server
if [[ $? -eq 0 ]]; then
  echo "Rails server exited without error code, but it probably shouldn't have. Container will now stop."
else
  echo "FATAL: Rails server exited with error code $?.  Container will now stop."
  exit 20
fi
