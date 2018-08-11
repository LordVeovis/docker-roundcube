[![License: GPL v3](https://img.shields.io/github/license/LordVeovis/docker-roundcube.svg)](https://www.gnu.org/licenses/gpl-3.0) [![](https://img.shields.io/docker/pulls/veovis/roundcube.svg)](https://hub.docker.com/r/veovis/roundcube/ 'Docker Hub') [![](https://img.shields.io/docker/build/veovis/roundcube.svg)](https://hub.docker.com/r/veovis/roundcube/builds/ 'Docker Hub')

# docker-roundcube
A docker image for running roundcube

# About
This is a docker image based on php:7-fpm-alpine for compacity.

# Parameters

## Volumes
* /var/www/html/config/config.inc.php: the configuration file of Roundcube
* /root_overlay: the content of this folder will be merged with the stock roundcube of the image
