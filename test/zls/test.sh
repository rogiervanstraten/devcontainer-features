#!/bin/bash

set -e

source dev-container-features-test-lib

check "zig version" zig version | grep "$(zig version)"
check "zls --version" zls --version | grep "$(zig version)"

reportResults