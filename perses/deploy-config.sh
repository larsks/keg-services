#!/bin/sh
set -e

ssh keg.house mkdir -p /volume1/docker/perses/config/provisioning
scp -O config.yaml keg.house:/volume1/docker/perses/config/

# DSM's rsync binary is setuid-root and PAM rejects it over a non-interactive
# ssh exec, so we use lftp's sftp mirror instead to keep provisioning/ in
# sync (including deleting files removed locally). Note: Synology's SFTP
# server is chrooted to /volume1, so paths here drop that prefix.
lftp -c "open sftp://keg.house; mirror --reverse --delete --verbose provisioning /docker/perses/config/provisioning"
