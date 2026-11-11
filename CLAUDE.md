This project contains a collection docker compose stacks that target a Synology DiskStation DS218+ (hostname "keg.house"). The diskstation is a remote docker host, with access configured via the DOCKER_HOST environment variable. This environment variable is set automatically via direnv so it should already be set.

Since we are targeting a remote system, we can't bind mount files from the local filesystem. We prefer embedding configuration files into a custom image via a `Containerfile` (built with `docker compose`'s `build` action) over bind mounting, since this makes it much easier to operate against a remote docker host — a config change is deployed just by rebuilding and recreating the container, with no file sync step. Each service directory that follows this pattern has its own `Containerfile` that `COPY`s its config files into the image; `compose.yaml` then uses `build: context: .` instead of a `volumes:` bind mount for that config.

The only thing that still relies on the old bind-mount-from-a-mirrored-repo approach is `garage`'s secrets (`garage/secrets/`), because secrets are gitignored and must never be baked into an image. See "Deploying config changes" below for how and when to push those.

The environment is managed with a top-level `compose.yaml` which includes individual `compose.yaml` files from each directory. `docker compose` must always be run from the top level. To start the entire stack:

    docker compose start

To start an individual container:

    docker compose start perses

To work against the local Docker daemon instead of the remote diskstation, `unset DOCKER_HOST` for that shell, or use `podman` to run containers locally.

## Deploying config changes

For a service built from a `Containerfile` (the default now — see above), editing a config file has no effect until you rebuild and recreate the container, since the file is baked into the image rather than bind mounted:

    docker compose up -d --build <service>

`docker compose` builds the image from the local `Containerfile` and pushes it to the remote docker host as part of `up -d`, so there's no separate sync step — unlike the old bind-mount approach, this works fine with uncommitted local changes.

The only remaining bind mount is `garage`'s secrets (`garage/secrets/`), which still relies on mirroring this repo to `/volume1/docker/services` on the remote host, because secrets are gitignored and must never be baked into an image. Run the top-level `deploy-config.sh` to push `garage/secrets/` (and anything else still under a legacy bind mount) to the remote host, then `docker compose restart garage` to pick it up. `docker compose up -d` will NOT restart a container whose `compose.yaml` itself hasn't changed, so it won't pick up a bind-mounted config-only change on its own.

`deploy-config.sh` refuses to run if any tracked file has uncommitted changes (checked via `git status --porcelain --untracked-files=no`), then `ssh`es a `rm -rf` of the remote `/volume1/docker/services` and repopulates it from `git archive HEAD` piped into a remote `tar` — so the remote host always matches a committed snapshot of this repo exactly, with no exclude-list to maintain when a new config file or service directory is added. Since `git archive` only includes committed files, a new config file that hasn't been committed yet simply won't be deployed — it won't block the sync, but it also won't show up on the remote host until you commit it. Any remaining bind mounts point at `/volume1/docker/services/<dir>/<file>`, matching this repo's own layout.

`garage/secrets/` is gitignored (secrets should never be committed), so it's excluded from the `git archive` and pushed separately via `scp` at the end of `deploy-config.sh`, with permissions fixed up afterward via `ssh ... chmod 600`.

Each service's persistent data (logs, uploaded files, database/state volumes) lives outside `/volume1/docker/services` on the remote host — e.g. `/volume1/docker/syslog/logs`, `/volume1/docker/sftp`, `/volume1/docker/traefik`, `/volume1/garage` — specifically so the `rm -rf`/re-archive never touches it. When adding a new service with persistent host-side data, give it a path outside `/volume1/docker/services`.

## Synology host quirks

- Plain `rsync` to keg.house does not work reliably (a PAM/setuid issue execing rsync over the transport) — this is why `deploy-config.sh` pipes a `git archive` into a remote `tar` over a plain `ssh` exec instead.

## Conventions

All actively-running service containers should have `restart: unless-stopped` set.
