#!/bin/bash

set -e

source dev-container-features-test-lib

check "forge version matches specified commit" bash -c "forge -V | grep '5b7e4cb'"

reportResults
