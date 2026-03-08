#!/usr/bin/env bash

CTID=200

pct exec $CTID -- bash -c "

mkdir -p /opt/stack
cd /opt/stack

cat <<EOF > docker-compose.yml

version: '3.9'

services:

  dockhand:
    image: fnsys/dockhand:latest
    container_name: dockhand
    ports:
      - 3000:3000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - dockhand_data:/app/data
    restart: unless-stopped

  traefik:
    image: traefik:v3
    command:
      - --api.insecure=true
      - --providers.docker=true
      - --entrypoints.web.address=:80
    ports:
      - 80:80
      - 8080:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

  watchtower:
    image: containrrr/watchtower
    command: --cleanup --interval 21600
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

volumes:
  dockhand_data:

EOF

docker compose up -d

"
