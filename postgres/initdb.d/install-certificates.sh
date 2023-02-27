#!/bin/sh

set -e

for file in /certs/*; do
	echo "installing $file"
	install -m 600 -o postgres -g postgres "$file" /var/lib/postgresql/data/
done
