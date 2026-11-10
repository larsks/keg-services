#!/bin/bash

SERVICE_DIR=/volume1/docker/services/

set -e

if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "${0##*/}: tracked files have uncommitted changes; commit or stash them first" >&2
  exit 1
fi

ssh keg.house "rm -rf $SERVICE_DIR"
git archive HEAD --prefix "$SERVICE_DIR" | ssh keg.house tar -C / -xf-

# garage/secrets/ is gitignored and never committed, so it isn't part of the
# archive above and has to be pushed separately.
ssh keg.house mkdir -p "${SERVICE_DIR}garage/secrets"
scp -O garage/secrets/rpc_secret garage/secrets/admin_token garage/secrets/metrics_token \
  keg.house:"${SERVICE_DIR}garage/secrets/"
ssh keg.house chmod 600 \
  "${SERVICE_DIR}garage/secrets/"*
