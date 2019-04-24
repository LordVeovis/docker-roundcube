FROM php:7-fpm-alpine

LABEL maintainer Veovis

ENV version 1.3.9

# install required modules
RUN apk add libzip && \
    apk add --no-cache --virtual _build zlib-dev libzip-dev && \
    docker-php-ext-install pdo_mysql zip && \
    apk del _build

# dl roundcube source code
RUN wget -O - "https://github.com/roundcube/roundcubemail/releases/download/$version/roundcubemail-$version-complete.tar.gz" | tar -xvz && \
    find roundcubemail-$version -maxdepth 1 -exec mv {} . \; && \
    rmdir roundcubemail-$version && \
    chown -R www-data:www-data . && \
    chmod -R a=rX . && \
    chmod -R u+w logs temp

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]

VOLUME /var/www/html