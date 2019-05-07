#!/usr/bin/env bash

# Do installation of nginx here

git clone https://github.com/mbeham/nodejs-demo-app.git /home/ubuntu/sample-node-app

# do stuff as root user (sudo)
sudo bash -e <<SCRIPT

apt-get install -y nodejs npm

cd /home/ubuntu/sample-node-app
npm install

# copy .service file to ubunto-directory and enable it
mv /home/ubuntu/sample-node-app/contrib/hello.service /etc/systemd/system/hello.service
systemctl enable hello

SCRIPT
