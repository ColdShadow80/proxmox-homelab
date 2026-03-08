#!/usr/bin/env bash

CTID=200
HOSTNAME=docker-host
PASSWORD=changeme

pveam update

pveam download local debian-12-standard_*.tar.zst

pct create $CTID local:vztmpl/debian-12-standard_*.tar.zst \
  --hostname $HOSTNAME \
  --cores 2 \
  --memory 4096 \
  --rootfs local-lvm:20 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1,keyctl=1 \
  --password $PASSWORD

pct start $CTID
