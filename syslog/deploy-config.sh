#!/bin/sh

ssh keg.house mkdir -p /volume1/docker/syslog/config/
scp -O syslog-ng.conf vector.yaml loki-config.yaml keg.house:/volume1/docker/syslog/config/
