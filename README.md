[![License: GPL v3](https://img.shields.io/github/license/LordVeovis/docker-roundcube.svg)](https://www.gnu.org/licenses/gpl-3.0) [![](https://img.shields.io/docker/pulls/veovis/roundcube.svg)](https://hub.docker.com/r/veovis/roundcube/ 'Docker Hub') [![](https://img.shields.io/docker/build/veovis/roundcube.svg)](https://hub.docker.com/r/veovis/roundcube/builds/ 'Docker Hub') [![GitHub tag](https://img.shields.io/github/tag/LordVeovis/docker-roundcube.svg)](https://GitHub.com/LordVeovis/docker-roundcube/tags/)

# docker-roundcube
A docker image for running roundcube

# About
This is a docker image based on php:7-fpm-alpine for compacity.

Please checkout the git repository for a ready to use nginx.conf and docker-compose.yml.

# Parameters

## Volumes

* /var/www/html/config/config.inc.php: the configuration file of Roundcube
* /root_overlay: the content of this folder will be merged with the stock roundcube of the image. This is where you put all plugins and skins and eventually modified roundcube source code.
* /var/www/html: roundcube source code

## Environment variables

* MAX_UPLOAD_SIZE: the maximum size of a file upload, example: 20M

# How to update

On the first run of this container, a volume is created with the content of /var/www/html, which contains the roundcube application and eventually modified files presents in /root_overlay. When this container is updated, the volumes associated to it are NOT recreated. This means that even if you run a new roundcube image, the roundcube website will not be updated. You have to destroy the volume for the update to really apply.

For simple installations, the update process can be done with the following commands: `docker-compose down -v && docker-compose up -d`