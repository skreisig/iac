#!/usr/bin/env bash
set -e

# Install some base packages useful on all machines
sudo bash -e <<SCRIPT

mv /tmp/nodejs.env /etc/nodejs.env
systemctl enable hello.service
systemctl start hello.service

SCRIPT