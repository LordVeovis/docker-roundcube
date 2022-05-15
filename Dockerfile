FROM php:7-fpm-alpine

LABEL maintainer Veovis

ENV version 1.5.2

# install required modules
RUN set -xe; \
    apk add --no-cache icu-libs jq git libldap libpng libzip php7-pecl-imagick; \
    apk add --no-cache --virtual _build icu-dev libpng-dev openldap-dev zlib-dev libzip-dev; \
    docker-php-ext-install gd exif intl ldap pdo_mysql sockets zip; \
    apk del --no-cache _build

# install composer
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
RUN set -xe; \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O - -q | php -- --quiet; \
    mv composer* /usr/local/bin/composer

# dl roundcube source code
RUN set -xe; \
    wget -O - "https://github.com/roundcube/roundcubemail/releases/download/$version/roundcubemail-$version-complete.tar.gz" | tar -xvz && \
    find roundcubemail-$version -maxdepth 1 -exec mv {} . \; && \
    rmdir roundcubemail-$version && \
    chown -R www-data:www-data . && \
    chmod -R a=rX . && \
    chmod -R u+w logs temp

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]

VOLUME /var/www/html