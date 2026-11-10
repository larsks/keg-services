This project contains a collection docker compose stacks that target a Synology DiskStation DS218+ (hostname "keg.house"). The diskstation is a remote docker host, with access configured via the DOCKER_HOST environment variable. This environment variable is set automatically via direnv so it should already be set.

Since we are targeting a remote system, we can't bind mount files from the local filesystem. We are handling this by copying files to the remote system and bind mounting them from there. There are `deploy-config.sh` scripts in each directory that needs to copy files to the remote host — see "Deploying config changes" below for how and when to run them.

The environment is managed with a top-level `compose.yaml` which includes individual `compose.yaml` files from each directory. `docker compose` must always be run from the top level. To start the entire stack:

    docker compose start

To start an individual container:

    docker compose start perses

To work against the local Docker daemon instead of the remote diskstation, `unset DOCKER_HOST` for that shell, or use `podman` to run containers locally.

## Deploying config changes

Editing a local config file (e.g. a Perses dashboard YAML, `prometheus.yml`) has no effect until you: (1) run that directory's `deploy-config.sh` to push the updated file to the remote host, and (2) run `docker compose restart <service>` to make the container pick it up. `docker compose up -d` will NOT restart a container whose `compose.yaml` itself hasn't changed, so it won't pick up a config-only change on its own.

Most `deploy-config.sh` scripts `scp` individually named files, which is safe. In situations where we need to synchronize the contents of a whole directory (e.g. `perses`'s `provisioning/*`), we use `lftp mirror --delete` instead of a wildcard `scp` copy — plain `scp` copies don't delete files that were removed locally, which can leave stale files behind on the remote host.

## Synology host quirks

- Plain `rsync` to keg.house does not work reliably (a PAM/setuid issue execing rsync over the transport) — this is why `lftp` over SFTP is used instead.
- SFTP access is chrooted to `/volume1`, so paths over SFTP/lftp drop that prefix (e.g. `/volume1/docker/...` on the host is just `/docker/...` via SFTP/lftp).

## Conventions

All actively-running service containers should have `restart: unless-stopped` set.
