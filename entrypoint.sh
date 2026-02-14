#!/usr/bin/env bash
set -o pipefail

cd "${GITHUB_WORKSPACE}" || exit 1

git config --global --add safe.directory "${GITHUB_WORKSPACE}"

ruby /action/lib/main.rb
