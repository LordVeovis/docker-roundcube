FROM php:8.4-fpm-alpine

LABEL maintainer=Veovis

ENV version=1.6.11

# install required modules
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache icu-libs jq git libldap libpng libzip php84-pecl-imagick; \
    apk add --no-cache --virtual _build icu-dev libpng-dev openldap-dev zlib-dev libzip-dev linux-headers; \
    docker-php-ext-install -j"$(nproc)" gd exif intl ldap pdo_mysql sockets zip; \
    apk del --no-cache _build

SHELL ["/bin/ash", "-xeo", "pipefail", "-c"]

# install composer
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
RUN wget -O - -q https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer | php -- --quiet; \
    mv composer* /usr/local/bin/composer

# dl roundcube source code
# hadolint ignore=DL3047
RUN wget -O - "https://github.com/roundcube/roundcubemail/releases/download/$version/roundcubemail-$version-complete.tar.gz" | tar -xvz; \
    find roundcubemail-$version -maxdepth 1 -exec mv {} . \;; \
    rmdir roundcubemail-$version; \
    chown -R www-data:www-data .; \
    chmod -R a=rX .; \
    chmod +x bin; \
    chmod -R u+w logs temp

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]

VOLUME /var/www/html