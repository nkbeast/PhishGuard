#!/bin/bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
WHITE="\033[1;37m"
RESET="\033[0m"

# Banner
banner() {
cat << "EOF"

     +--^----------,--------,-----,--------^-,       
     | |||||||||   '--------'     |          O       
     `+---------------------------^----------|       
       `\_,---------,---------,--------------'       
         / XXXXXX /'|       /'                        
        / XXXXXX /  `\    /'                         
       / XXXXXX /`-------'                          
      / XXXXXX /                                     
     / XXXXXX /                                      
    (________(                By NK             
     `------'                                        

┌────────────────────────────────────────────────────┐
│  🎯 PHISHGUARD - DMARC MISCONFIGURATION SNIPER     │
└────────────────────────────────────────────────────┘
EOF
}

# Usage
usage() {
    echo -e "${WHITE}Usage:${RESET}"
    echo "  $0 -d <domain> [-v] [--html]         # Scan a single domain"
    echo "  $0 -l <file> [-v] [--html]           # Scan a list of domains"
    exit 1
}

# Variables
html=false
verbose=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain) domain="$2"; shift 2;;
        -l|--list) file="$2"; shift 2;;
        -v|--verbose) verbose=true; shift;;
        -r|--report|--html) html=true; shift;;
        *) echo -e "\n${RED}Unknown parameter: $1${RESET}"; usage;;
    esac
done

[[ -z "$domain" && -z "$file" ]] && usage

# Spinner
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\\'
    while [ -d "/proc/$pid" ]; do
        for c in $spinstr; do
            echo -ne "\r${BLUE}[🔎] Scanning... $c${RESET}"
            sleep $delay
        done
    done
    echo -ne "\r${GREEN}[✔] Scan completed.${RESET}\n"
}

# Clean domain (strip protocol and trailing slash)
clean_domain() {
    echo "$1" | sed -e 's~http[s]*://~~g' -e 's/\/$//' | cut -d'/' -f1
}

# DNS check
check_dns() {
    dig +short "$1" > /dev/null
    return $?
}

# MX check
check_mx() {
    dig MX +short "$1" | grep -q "."
    return $?
}

# DMARC check
check_dmarc() {
    record=$(dig TXT _dmarc."$1" +short | tr -d '"')
    if [[ "$record" == *"p=none"* || -z "$record" ]]; then
        return 0
    else
        return 1
    fi
}

# HTML Report Generator
write_html_report() {
    local html_file="$(dirname "$0")/phishguard_report_$(date +%Y%m%d_%H%M%S).html"
    {
        echo "<html><head><title>PhishGuard Report</title>"
        echo "<style>
            body { background:#111; color:#eee; font-family: Arial; padding: 20px; }
            h1 { color: #f33; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            th, td { border: 1px solid #444; padding: 10px; }
            th { background-color: #222; }
            tr:nth-child(even) { background-color: #1a1a1a; }
            .vulnerable { color: #f55; font-weight: bold; }
        </style></head><body>"

        echo "<h1>📋 PhishGuard - DMARC Misconfigurations</h1>"
        echo "<p><strong>Generated:</strong> $(date)</p>"

        if [[ ${#htmlrows[@]} -eq 0 ]]; then
            echo "<p>No vulnerable domains found.</p>"
        else
            echo "<table><tr><th>Domain</th><th>DNS</th><th>MX</th><th>DMARC</th><th>Status</th></tr>"
            for row in "${htmlrows[@]}"; do
                echo "$row"
            done
            echo "</table>"
        fi

        echo "</body></html>"
    } > "$html_file"
    echo -e "\n${GREEN}[✔] HTML report saved to: $html_file${RESET}\n"
}

# Scan single domain
scan_domain() {
    local d=$1
    d=$(clean_domain "$d")
    [[ -z "$d" ]] && return

    local dns="❌"
    local mx="❌"
    local dmarc="❌"
    local row="<tr><td>$d</td>"

    if ! check_dns "$d"; then
        $verbose && echo -e "${BLUE}[SKIPPED]${RESET} $d → No DNS record"
        return
    else
        dns="✅"
    fi

    if ! check_mx "$d"; then
        $verbose && echo -e "${BLUE}[SKIPPED]${RESET} $d → No MX record"
        return
    else
        mx="✅"
    fi

    if check_dmarc "$d"; then
        echo -e "${RED}[VULNERABLE]${RESET} $d → DMARC policy not enabled"
        dmarc="❌"
        vulnerables+=("$d")
        row+="<td>$dns</td><td>$mx</td><td>$dmarc</td><td class='vulnerable'>VULNERABLE</td></tr>"
        htmlrows+=("$row")
    else
        $verbose && echo -e "${GREEN}[SECURE]${RESET} $d → DMARC policy enforced"
    fi
}

# Start
banner
vulnerables=()
htmlrows=()

# Run scan
if [[ -n "$domain" ]]; then
    scan_domain "$domain"
elif [[ -n "$file" ]]; then
    mapfile -t lines < "$file"
    for d in "${lines[@]}"; do
        scan_domain "$d" &
        wait $!
    done
fi

# Generate HTML if needed
if $html && [[ ${#vulnerables[@]} -gt 0 ]]; then
    write_html_report
fi
