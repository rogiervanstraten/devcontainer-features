#!/bin/bash

set -e

source dev-container-features-test-lib

check "aws-vault in PATH" command -v aws-vault

check "aws-vault --version" aws-vault --version | grep "$(aws-vault --version)"

reportResults