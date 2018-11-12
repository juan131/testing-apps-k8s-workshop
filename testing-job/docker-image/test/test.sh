#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Set Testing Mode
TESTING_MODE=${TESTING_MODE:-"staging"}

if [[ "$TESTING_MODE" = "production" ]] || [[ "$TESTING_MODE" = "staging" ]]; then
  # Tests that are executed both on production and staging
  /test/node_modules/.bin/mocha --timeout 5000 /test/verification/common-tests.js

  ## Uncomment for exercise03
  # /test/node_modules/.bin/casperjs test /test/functional/login.js
  # /test/node_modules/.bin/casperjs test /test/functional/clickOnPageMenu.js

  if [[ "$TESTING_MODE" = "staging" ]]; then
    # Tests that are only executed on staging
    /test/node_modules/.bin/mocha --timeout 20000 /test/verification/mongo-tests.js
  fi

else
    echo "Testing Mode \"$TESTING_MODE\" not supported"
    echo " - Supported Testing Modes are: production and staging"
fi
