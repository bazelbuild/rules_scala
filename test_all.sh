#!/bin/bash

set -euo pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"${dir}"/test_rules_scala.sh
"${dir}"/test_version.sh
"${dir}"/test_reproducibility.sh
"${dir}"/test_intellij_aspect.sh
