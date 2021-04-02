#!/usr/bin/env bash

set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
project_root="$( cd "$script_dir" && cd .. && pwd )"
config_filename="$project_root/.swiftlint.yml"

mint="/usr/local/bin/mint"

if which "$mint" > /dev/null
then
    "$mint" run realm/SwiftLint@0.43.1 swiftlint lint --config "$config_filename" $@
else
    echo "warning: Cannot invoke swiftlint as mint is not installed. See README.md for installation instructions"
fi

