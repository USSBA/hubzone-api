#!/bin/bash

echo "Starting db:create db:migrate..."
bundle exec rake db:create db:migrate
if [[ $? -eq 0 ]]; then
  echo "Done db:create db:migrate"
else
  echo "FATAL: db:migrate failed.  Container will now stop."
  exit 10
fi
echo "Starting rails server..."
bundle exec rails server
if [[ $? -eq 0 ]]; then
  echo "Rails server exited without error code, but it probably shouldn't have. Container will now stop."
else
  echo "FATAL: Rails server exited with error code $?.  Container will now stop."
  exit 20
fi
