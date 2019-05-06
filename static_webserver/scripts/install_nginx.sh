#!/usr/bin/env bash

# Do installation of nginx here

sudo bash -e <<SCRIPT

apt-get install nginx

mv /tmp/index.html /var/www/html/index.html

SCRIPT