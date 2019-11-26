#!/bin/bash
#
#   Erstellt wg0.conf und die Keys fuer WireGuard Server und Clients
#
umask 077

### Defaults
NET=12
ENDPOINT=<gateway>
PORT=51820

### Server
wg genkey > server_private.key
wg pubkey > server_public.key < server_private.key

cat <<%EOF% >wg0.conf
[Interface]
Address = 192.168.${NET}.1
ListenPort = ${PORT}
#PostUp = sysctl -w net.ipv4.ip_forward=1
#PreDown = sysctl -w net.ipv4.ip_forward=0
PrivateKey = $(cat server_private.key)
%EOF%

### Clients
for client in {10..40}
do
        wg genkey > client_${client}_private.key
        wg pubkey > client_${client}_public.key < client_${client}_private.key
        cat <<%EOF% >client_${client}_wg0.conf
[Interface]
Address = 192.168.${NET}.${client}/24
PrivateKey = $(cat client_${client}_private.key)

[Peer]
PublicKey = $(cat server_public.key)
Endpoint = ${ENDPOINT}:${PORT}

AllowedIPs = 192.168.${NET}.0/24

# This is for if you're behind a NAT and
# want the connection to be kept alive.
PersistentKeepalive = 25
%EOF%

cat <<%EOF% >>wg0.conf

### Client ${client}
[Peer]
PublicKey = $(cat client_${client}_public.key)
AllowedIPs = 192.168.${NET}.${client}
%EOF%

done
