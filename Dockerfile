FROM php:7-fpm-alpine

LABEL maintainer Veovis

ENV version 1.3.7

RUN wget -O - "https://github.com/roundcube/roundcubemail/releases/download/$version/roundcubemail-$version-complete.tar.gz" | tar -xvz && \
    find roundcubemail-$version -maxdepth 1 -exec mv {} . \; && \
    rmdir roundcubemail-$version && \
    chown -R www-data:www-data . && \
    chmod -R a=rX . && \
    chmod -R u+w logs temp

COPY docker-entrypoint.sh /
VOLUME /var/www/html/logs