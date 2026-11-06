#!/bin/sh

ssh keg.house mkdir -p /volume1/docker/garage/config /volume1/docker/garage/secrets
scp -O garage.toml keg.house:/volume1/docker/garage/config/
scp -O secrets/rpc_secret secrets/admin_token secrets/metrics_token keg.house:/volume1/docker/garage/secrets/
ssh keg.house chmod 600 /volume1/docker/garage/secrets/rpc_secret /volume1/docker/garage/secrets/admin_token /volume1/docker/garage/secrets/metrics_token
