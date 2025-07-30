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
│  🎯 PHISHGUARD - DMARC & SPF MISCONFIGURATION TOOL │
└────────────────────────────────────────────────────┘
                                         Coded by: @nk
EOF
}

# Help menu
print_help() {
    echo -e "${WHITE}Usage:${RESET}"
    echo -e "  $0 domain.com                       → Scan single domain"
    echo -e "  $0 -l list.txt                     → Scan list of domains"
    echo -e "     [--output result.txt]          → Save results to file"
    echo -e "     [--webhook <url>]              → Send result to Discord"
    echo -e "     [--vuln]                        → Show only P3/P4 vulnerabilities"
    echo -e "     [--help]                        → Show this help message"
}

# Strip https://, http:// and trailing /
sanitize_domain() {
    echo "$1" | sed -E 's#^https?://##; s#/$##'
}

# List of legitimate mail providers
trusted_mx=(
  "gmail.com" "google.com" "googlemail.com" "apple.com"
  "outlook.com" "hotmail.com" "live.com" "msn.com"
  "yahoo.com" "ymail.com" "rocketmail.com" "icloud.com"
  "gmx.com" "gmx.de" "mail.com" "mail.ru" "zoho.com" "zohomail.com"
  "protonmail.com" "tutanota.com" "mailfence.com" "startmail.com" "mailbox.org"
  "mimecast.com" "proofpoint.com" "barracudanetworks.com"
  "sendgrid.net" "mailgun.org" "sparkpostmail.com" "smtp.com"
  "emailsrvr.com" "amazonaws.com" "amazonses.com"
  "mailchannels.net" "constantcontact.com" "mailchimp.com"
  "rackspace.com" "bluehost.com" "hostgator.com" "siteground.com" "titan.email"
  "ionos.com" "1and1.com" "fastmail.com" "gcorelabs.net"
)


# Improved MX filter using trusted base domains
check_mx_provider() {
    local domain=$1
    local valid_mx=false
    mx_records=$(dig MX +short "$domain")

    while IFS= read -r line; do
        mx_host=$(echo "$line" | awk '{print $2}' | sed 's/\.$//')
        [[ -z "$mx_host" || "$mx_host" != *.* ]] && continue
        mx_domain=$(echo "$mx_host" | awk -F'.' '{if (NF>=2) print $(NF-1)"."$NF}')
        for trusted in "${trusted_mx[@]}"; do
            if [[ "$mx_domain" == "$trusted" ]]; then
                valid_mx=true
                break 2
            fi
        done
    done <<< "$mx_records"

    $valid_mx && return 0 || return 1
}



# Get SPF record type
get_spf_type() {
    local domain=$1
    spf_record=$(dig +short TXT "$domain" | grep -i "v=spf1" | tr -d '"')
    if [[ -z "$spf_record" ]]; then
        echo "none"
    elif [[ "$spf_record" == *"~all"* ]]; then
        echo "weak"
    else
        echo "strong"
    fi
}

# Get DMARC policy
get_dmarc_policy() {
    local domain=$1
    dmarc_record=$(dig +short TXT _dmarc."$domain" | tr -d '"')
    if [[ -z "$dmarc_record" ]]; then
        echo "missing"
    elif echo "$dmarc_record" | grep -q "p=none"; then
        echo "weak"
    else
        echo "strong"
    fi
}

# Classify domain
classify_domain() {
    local domain=$1
    local output=""

    if ! dig +short NS "$domain" > /dev/null || [[ -z $(dig +short NS "$domain") ]]; then
        output="${WHITE}[SKIPPED] $domain → DNS resolution failed or domain not found${RESET}"
        [[ "$VULN_ONLY" == true ]] && return 1 || { echo -e "$output"; return 1; }
    fi

    # 🔐 MX filter
    if ! check_mx_provider "$domain"; then
        [[ "$VULN_ONLY" == true ]] && return 1 || {
            echo -e "${BLUE}[SKIPPED] $domain → MX not from trusted mail providers${RESET}"
            return 1
        }
    fi

    spf_status=$(get_spf_type "$domain")
    dmarc_status=$(get_dmarc_policy "$domain")

    if [[ "$spf_status" == "none" && "$dmarc_status" == "missing" ]]; then
        output="${RED}[VULNERABLE P3] $domain → SPF missing + DMARC missing${RESET}"
    elif [[ "$spf_status" == "weak" && "$dmarc_status" == "missing" ]]; then
        output="${RED}[VULNERABLE P3] $domain → Weak SPF (~all) + Missing DMARC${RESET}"
    elif [[ "$spf_status" == "none" && "$dmarc_status" == "weak" ]]; then
        output="${RED}[VULNERABLE P3] $domain → SPF missing + Weak DMARC (p=none)${RESET}"
    elif [[ "$spf_status" == "weak" && "$dmarc_status" == "weak" ]]; then
        output="${RED}[VULNERABLE P3] $domain → Both SPF and DMARC are weak (p=none, ~all)${RESET}"
    elif [[ "$spf_status" != "none" && "$dmarc_status" == "weak" ]]; then
        output="${RED}[VULNERABLE P4] $domain → SPF present but DMARC policy is weak (p=none)${RESET}"
    else
        output="${GREEN}[SAFE] $domain → SPF: $spf_status | DMARC: $dmarc_status${RESET}"
        [[ "$VULN_ONLY" == true ]] && return 1
    fi

    echo -e "$output"
    [[ -n "$WEBHOOK" ]] && curl -s -H "Content-Type: application/json" -X POST -d "{\"content\":\"$output\"}" "$WEBHOOK" > /dev/null
    [[ -n "$OUTPUT_FILE" ]] && echo -e "$output" >> "$OUTPUT_FILE"
}


# Args
LIST_FILE=""
WEBHOOK=""
OUTPUT_FILE=""
VULN_ONLY=false

# Parse CLI args
while [[ $# -gt 0 ]]; do
    case $1 in
        --list|-l)
            LIST_FILE="$2"
            shift 2
            ;;
        --webhook|-w)
            WEBHOOK="$2"
            shift 2
            ;;
        --output|-o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --vuln|-vuln)
            VULN_ONLY=true
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            TARGET_DOMAIN="$1"
            shift
            ;;
    esac
done

banner

# List scanning
if [[ -n "$LIST_FILE" ]]; then
    while read -r raw_domain; do
        [[ -z "$raw_domain" ]] && continue
        domain=$(sanitize_domain "$raw_domain")
        classify_domain "$domain"
    done < "$LIST_FILE"

# Single domain
elif [[ -n "$TARGET_DOMAIN" ]]; then
    cleaned_domain=$(sanitize_domain "$TARGET_DOMAIN")
    classify_domain "$cleaned_domain"

# Show help if nothing passed
else
    print_help
fi
