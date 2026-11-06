#!/bin/sh

ssh keg.house mkdir -p /volume1/docker/prometheus/config
scp -O prometheus.yml keg.house:/volume1/docker/prometheus/config/
