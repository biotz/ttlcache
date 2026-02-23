#!/usr/bin/env bash

set -eu -o pipefail

if [[ $(docker-compose config | grep -Fc ': null') -gt 0 ]]; then
    echo "Error: Some environment variables are missing:"
    docker-compose config | awk -F':' '/: null/ {print $1}'
    exit 1
else
    exit 0
fi
