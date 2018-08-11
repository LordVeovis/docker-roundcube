#!/bin/sh

ROOT_OVERLAY=/root_overlay
ROOT_WWW=/var/www/html

if [ -d "$ROOT_OVERLAY" ]; then
    echo "Merging overlay with stock roundcube"

    cd "$ROOT_OVERLAY"
    find . \( -type f -o -type l \) -print | \
        while read i;
        do
            d=`dirname "$i"`
            [ -d "$d" ] || mkdir "$d"
            cp "$i" "$ROOT_WWW/"
        done
fi

exec docker-php-entrypoint "$@"