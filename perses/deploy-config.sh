#!/bin/sh

ssh keg.house mkdir -p /volume1/docker/perses/config/ /volume1/docker/perses/config/provisioning/
scp -O config.yaml keg.house:/volume1/docker/perses/config/
scp -O provisioning/* keg.house:/volume1/docker/perses/config/provisioning/
