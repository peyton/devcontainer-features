#!/bin/bash

set -e

source dev-container-features-test-lib

check "execute forge version" bash -c "forge -V | grep 'forge'"

reportResults
