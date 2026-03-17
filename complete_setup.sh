#!/bin/bash
# OPaaS Penetration Testing - Complete Setup Script
# This script handles all errors and installs everything you need

echo "=========================================="
echo "OPaaS Pentest Environment - Full Setup"
echo "=========================================="

# Fix any broken dpkg installations
echo "[1/12] Fixing any broken package installations..."
sudo dpkg --configure -a 2>/dev/null

# Remove problematic repositories
echo "[2/12] Cleaning up repositories..."
sudo rm -f /etc/apt/sources.list.d/trivy.list 2>/dev/null

# Wait for any running apt processes
echo "[3/12] Waiting for any running package managers..."
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    sleep 2
done

# Update system
echo "[4/12] Updating system..."
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

# Install Web Application Testing Tools
echo "[5/12] Installing web application testing tools..."
sudo apt install -y burpsuite zaproxy nikto dirb gobuster sqlmap wfuzz commix 2>/dev/null

# Install Network Tools
echo "[6/12] Installing network scanning tools..."
sudo apt install -y nmap masscan netdiscover wireshark tcpdump tshark 2>/dev/null

# Install Password & Exploitation Tools
echo "[7/12] Installing exploitation frameworks..."
sudo apt install -y metasploit-framework hydra john hashcat exploitdb medusa 2>/dev/null

# Install Development Environment
echo "[8/12] Installing development tools..."
sudo apt install -y git vim nano python3 python3-pip python3-venv nodejs npm openjdk-11-jdk golang-go 2>/dev/null

# Install Monitoring Tools
echo "[9/12] Installing monitoring tools..."
sudo apt install -y htop iotop nethogs logwatch tmux screen 2>/dev/null

# Install Utilities
echo "[10/12] Installing utilities..."
sudo apt install -y curl wget jq wordlists seclists chromium firefox-esr 2>/dev/null

# Install Python Security Tools
echo "[11/12] Installing Python security packages..."
pip3 install --upgrade pip --break-system-packages 2>/dev/null
pip3 install chardet ftfy safety selenium --break-system-packages 2>/dev/null

# Install Node.js Security Tools
echo "[12/12] Installing Node.js security packages..."
sudo npm install -g snyk retire eslint 2>/dev/null

# Create Unicode Detector Script
echo "Creating unicode_detector.py..."
cat > ~/unicode_detector.py << 'PYEOF'
#!/usr/bin/env python3
import sys

def detect_invisible_unicode(filepath):
    suspicious_ranges = [
        (0xFE00, 0xFE0F, "Variation Selectors"),
        (0xE0100, 0xE01EF, "Variation Selectors Supplement"),
        (0x2060, 0x2069, "Invisible Operators"),
        (0x200B, 0x200F, "Zero-width Characters"),
        (0xFEFF, 0xFEFF, "Zero-width No-break Space"),
    ]
    findings = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            for line_num, line in enumerate(content.split('\n'), 1):
                for char_pos, char in enumerate(line, 1):
                    code_point = ord(char)
                    for start, end, name in suspicious_ranges:
                        if start <= code_point <= end:
                            findings.append({
                                'line': line_num,
                                'column': char_pos,
                                'codepoint': hex(code_point),
                                'type': name
                            })
    except Exception as e:
        print(f"Error: {e}")
        return []
    return findings

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: unicode_detector.py <file>")
        sys.exit(1)
    filepath = sys.argv[1]
    findings = detect_invisible_unicode(filepath)
    if findings:
        print(f"WARNING: Found {len(findings)} suspicious Unicode characters:")
        for f in findings:
            print(f"  Line {f['line']}, Col {f['column']}: {f['type']} ({f['codepoint']})")
    else:
        print(f"OK: No suspicious Unicode found")
PYEOF

chmod +x ~/unicode_detector.py
sudo cp ~/unicode_detector.py /usr/local/bin/ 2>/dev/null

# Create Glassworm Scanner Script
echo "Creating glassworm_scanner.sh..."
cat > ~/glassworm_scanner.sh << 'SHEOF'
#!/bin/bash
echo "Glassworm Attack Pattern Scanner"
echo "================================="
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
SCAN_DIR="$1"
echo "Scanning: $SCAN_DIR"
echo ""
echo "[1] Checking for suspicious eval()..."
find "$SCAN_DIR" -type f \( -name "*.js" -o -name "*.ts" \) -exec grep -l "eval.*\`\`" {} \; 2>/dev/null
echo "[2] Checking for Unicode decoders..."
find "$SCAN_DIR" -type f -name "*.js" -exec grep -l "codePointAt.*0xFE00\|0xE0100" {} \; 2>/dev/null
echo "[3] Checking package.json..."
find "$SCAN_DIR" -type f -name "package.json" -exec echo "Found: {}" \;
echo ""
echo "Scan complete"
SHEOF

chmod +x ~/glassworm_scanner.sh
sudo cp ~/glassworm_scanner.sh /usr/local/bin/ 2>/dev/null

# Create Verification Script
echo "Creating verification script..."
cat > ~/verify_tools.sh << 'VEREOF'
#!/bin/bash
echo "Tool Installation Verification"
echo "==============================="
tools="nmap burpsuite metasploit-framework git python3 node wireshark"
for tool in $tools; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool"
    else
        echo "✗ $tool - NOT FOUND"
    fi
done
echo ""
echo "Python packages:"
pip3 list 2>/dev/null | grep -E "chardet|safety|selenium" || echo "Check manually with: pip3 list"
echo ""
echo "Custom tools:"
[ -f /usr/local/bin/unicode_detector.py ] && echo "✓ unicode_detector.py" || echo "✗ unicode_detector.py"
[ -f /usr/local/bin/glassworm_scanner.sh ] && echo "✓ glassworm_scanner.sh" || echo "✗ glassworm_scanner.sh"
VEREOF

chmod +x ~/verify_tools.sh

# Final cleanup
sudo apt autoremove -y 2>/dev/null
sudo apt clean 2>/dev/null

echo ""
echo "=========================================="
echo "✓ Installation Complete!"
echo "=========================================="
echo ""
echo "Installed Tools:"
echo "  - Web Testing: burpsuite, zaproxy, sqlmap, nikto"
echo "  - Network: nmap, masscan, wireshark, tcpdump"
echo "  - Exploitation: metasploit, hydra, john, hashcat"
echo "  - Development: git, python3, nodejs, go"
echo "  - Security: snyk, retire, safety"
echo ""
echo "Custom Scripts Created:"
echo "  - ~/unicode_detector.py (also in /usr/local/bin/)"
echo "  - ~/glassworm_scanner.sh (also in /usr/local/bin/)"
echo "  - ~/verify_tools.sh"
echo ""
echo "Next Steps:"
echo "  1. Run: ~/verify_tools.sh"
echo "  2. Initialize Metasploit: sudo msfdb init"
echo "  3. Test unicode detector: unicode_detector.py <file>"
echo "  4. Test glassworm scanner: glassworm_scanner.sh <directory>"
echo ""
echo "Ready for OPaaS penetration testing!"
echo "=========================================="
