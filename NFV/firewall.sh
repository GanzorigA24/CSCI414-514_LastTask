#!/bin/bash
set -e

echo "=================================="
echo " NFV Virtual Firewall Starting"
echo "=================================="

# Enable Linux kernel IPv4 packet forwarding
sysctl -w net.ipv4.ip_forward=1

# Route return traffic for game_client (192.168.144.0/24) back through SDN swithch (192.168.147.252)
ip route replace 192.168.144.0/24 via 192.168.147.252

echo "Loading firewall rules..."
nft -f /etc/nftables.conf

echo ""
echo "Firewall rules loaded successfully."
echo ""

echo "Active firewall rules:"
nft list ruleset

echo ""
echo "NFV Virtual Firewall is running."

exec tail -f /dev/null
