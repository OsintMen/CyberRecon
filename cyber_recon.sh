#!/bin/bash
# Cyber Tool Demo: Safe Recon & System Info Collector
# Author: OsintMen
# GitHub: github.com/OsintMen

# Create output folder with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="recon_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

echo "[*] Recon started at $TIMESTAMP"

# 1. Collect basic system info
echo "[*] Collecting system info..."
uname -a > "$OUTPUT_DIR/system_info.txt"
df -h >> "$OUTPUT_DIR/system_info.txt"
free -h >> "$OUTPUT_DIR/system_info.txt"
echo "[+] System info saved."

# 2. List all active network interfaces
echo "[*] Listing network interfaces..."
ip addr show > "$OUTPUT_DIR/network_interfaces.txt"
echo "[+] Network interfaces saved."

# 3. Scan local network (safe ping sweep)
echo "[*] Scanning local network..."
SUBNET=$(ip route | grep -oP 'src \K[\d.]+')
BASE_IP=$(echo $SUBNET | cut -d. -f1-3)
for i in $(seq 1 254); do
    ping -c 1 -W 1 $BASE_IP.$i &> /dev/null && echo "$BASE_IP.$i is up" >> "$OUTPUT_DIR/active_hosts.txt" &
done
wait
echo "[+] Local network scan saved."

# 4. Check for open ports on localhost (safe)
echo "[*] Checking common ports on localhost..."
for PORT in 22 80 443 3306 5432; do
    (echo > /dev/tcp/127.0.0.1/$PORT) &>/dev/null && echo "Port $PORT is open" >> "$OUTPUT_DIR/open_ports.txt"
done
echo "[+] Open ports check completed."

echo "[*] Recon finished! Results saved in $OUTPUT_DIR"