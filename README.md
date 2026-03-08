# Proxmox Homelab Auto Deployment

Fully automated deployment of a modern homelab stack on **Proxmox VE** using Docker.

This project installs a complete container platform including:

- Dockhand (Docker management UI)
- Traefik (reverse proxy)
- Watchtower (automatic container updates)
- Cloudflare Tunnel (secure remote access)

The entire stack can be deployed with **one command** from the Proxmox host.

---

# Architecture

```
Internet
│
▼
Cloudflare Tunnel
│
▼
Traefik Reverse Proxy
│
├─ Dockhand
├─ Nextcloud (optional)
├─ Immich (optional)
├─ Uptime Kuma (optional)
└─ Other Docker apps
```

Running on:

```
Proxmox VE
└─ LXC Container
└─ Docker
├─ Dockhand
├─ Traefik
├─ Watchtower
└─ Cloudflare Tunnel
```

---

# Features

- One-command deployment
- Automatic Docker installation
- Secure remote access
- Reverse proxy with service discovery
- Automatic container updates
- Easily extendable with more services

---

# Requirements

Minimum recommended hardware:

| Resource | Minimum |
|--------|--------|
CPU | 2 cores |
RAM | 4 GB |
Disk | 20 GB |

Software:

- Proxmox VE 7 or 8
- Internet access

---

# Quick Start

Run this on your **Proxmox host**:

bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOURUSER/proxmox-homelab/main/bootstrap.sh)"


This script will:

1. Create a Debian LXC container
2. Install Docker
3. Install Docker Compose
4. Deploy the core stack
5. Start all services

---

# Access Services

After installation:

Dockhand UI

http://SERVER-IP:3000


Traefik dashboard

http://SERVER-IP:8080


---

# Repository Structure

```
proxmox-homelab
│
├── bootstrap.sh
│
├── scripts
│ ├── 01-create-lxc.sh
│ ├── 02-install-docker.sh
│ ├── 03-core-stack.sh
│ ├── 04-cloudflare-tunnel.sh
│ └── 05-summary.sh
│
└── stacks
└── docker-compose.yml
```

---

# Deployment Scripts

## bootstrap.sh

Main orchestration script that runs all installation steps.

#!/usr/bin/env bash

set -e

REPO="https://raw.githubusercontent.com/YOURUSER/proxmox-homelab/main"

echo "Starting Homelab Bootstrap..."

curl -fsSL $REPO/scripts/01-create-lxc.sh | bash
curl -fsSL $REPO/scripts/02-install-docker.sh | bash
curl -fsSL $REPO/scripts/03-core-stack.sh | bash
curl -fsSL $REPO/scripts/04-cloudflare-tunnel.sh | bash
curl -fsSL $REPO/scripts/05-summary.sh | bash

echo "Homelab deployment complete"


---

# Script: Create LXC Container

`scripts/01-create-lxc.sh`

#!/usr/bin/env bash

CTID=200
HOSTNAME=docker-host
PASSWORD=changeme

pveam update

TEMPLATE=$(pveam available | grep debian-12 | head -n1 | awk '{print $2}')

pveam download local $TEMPLATE

pct create $CTID local:vztmpl/$TEMPLATE
--hostname $HOSTNAME
--cores 2
--memory 4096
--rootfs local-lvm:20
--net0 name=eth0,bridge=vmbr0,ip=dhcp
--features nesting=1,keyctl=1
--password $PASSWORD

pct start $CTID


---

# Script: Install Docker

`scripts/02-install-docker.sh`

#!/usr/bin/env bash

CTID=200

pct exec $CTID -- bash -c "

apt update

apt install -y curl git

curl -fsSL https://get.docker.com | sh

apt install -y docker-compose-plugin

systemctl enable docker

"


---

# Script: Deploy Core Stack

`scripts/03-core-stack.sh`

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


---

# Script: Cloudflare Tunnel

`scripts/04-cloudflare-tunnel.sh`

#!/usr/bin/env bash

CTID=200

pct exec $CTID -- bash -c "

docker run -d
--name cloudflared
--restart unless-stopped
cloudflare/cloudflared:latest tunnel --no-autoupdate run

"


---

# Script: Summary

`scripts/05-summary.sh`

#!/usr/bin/env bash

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "Deployment finished"
echo ""
echo "Dockhand:"
echo "http://$IP:3000"
echo ""
echo "Traefik:"
echo "http://$IP:8080"


---

# Security Notes

Recommended improvements:

- Change default passwords
- Use HTTPS with Traefik
- Enable authentication proxy
- Restrict dashboard access

---

# Optional Additions

Popular containers to add:

- Nextcloud
- Immich
- Uptime Kuma
- Pi-hole
- Home Assistant

These can be deployed through Dockhand.

---

# Backup Strategy

Recommended:

- Proxmox LXC backups
- Docker volume backups
- Offsite backup with Restic

---

# License

MIT License

---

# Contributing

Pull requests and improvements are welcome.
