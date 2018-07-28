#! /bin/sh
set -eo pipefail
env | j2 --format=env /var/templates/php.ini.j2 > /usr/local/etc/php/php.ini
exec "$@"