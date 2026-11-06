#!/bin/sh

ssh keg.house mkdir -p /volume1/docker/grafana/config/datasources
scp -O datasources.yaml keg.house:/volume1/docker/grafana/config/datasources/
