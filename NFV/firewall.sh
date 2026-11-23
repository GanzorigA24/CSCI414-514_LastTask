#!/bin/bash
set -e

echo "=================================="
echo " NFV Virtual Firewall Starting"
echo "=================================="

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
