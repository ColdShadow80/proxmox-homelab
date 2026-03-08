#!/usr/bin/env bash

set -e

REPO="https://raw.githubusercontent.com/ColdShadow80/proxmox-homelab/main"

echo "Starting Homelab Bootstrap..."

curl -fsSL $REPO/scripts/01-create-lxc.sh | bash
curl -fsSL $REPO/scripts/02-install-docker.sh | bash
curl -fsSL $REPO/scripts/03-core-stack.sh | bash
curl -fsSL $REPO/scripts/04-cloudflare-tunnel.sh | bash
curl -fsSL $REPO/scripts/05-summary.sh | bash

echo "Homelab deployment complete"
