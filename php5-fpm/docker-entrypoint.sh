#! /bin/sh
set -eo pipefail
shopt -s nullglob
#env | j2 --format=env /var/templates/php.ini.j2 /usr/local/etc/php/php.ini
exec "$@"