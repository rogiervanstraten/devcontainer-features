#!/bin/bash

set -e

source dev-container-features-test-lib

check "novops in PATH" command -v novops

check "novops --version" novops --version | grep "$(novops --version)"

reportResults