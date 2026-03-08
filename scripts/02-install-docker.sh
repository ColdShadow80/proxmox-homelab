#!/usr/bin/env bash

CTID=200

pct exec $CTID -- bash -c "

apt update

apt install -y curl git

curl -fsSL https://get.docker.com | sh

apt install -y docker-compose-plugin

systemctl enable docker

"
