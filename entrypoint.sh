#!/usr/bin/env bash
set -o pipefail

cd "${GITHUB_WORKSPACE}" || exit 1

ruby /action/lib/main.rb
