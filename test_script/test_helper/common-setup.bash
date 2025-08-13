#!/opt/homebrew/bin/bash

_common_setup() {
# get the containing directory of this file
# use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
# as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_DIR="$( cd "$( dirname "$BATS_TEST_DIRNAME")" >/dev/null 2>&1 && pwd )"
# make executables in src/ visible to PATH
    PATH="$PROJECT_DIR/src:$PATH"
}
