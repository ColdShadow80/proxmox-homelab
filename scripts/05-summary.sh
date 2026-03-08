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
