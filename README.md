<h1 align="center">🎯 PhishGuard</h1>

<p align="center">
  <b>DMARC & SPF Misconfiguration Sniper</b><br>
  Identify phishing-prone domains by scanning DNS, MX, SPF, and DMARC in bulk.<br>
  Built for bug bounty hunters and security researchers.<br>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Made%20by-NK-blue?style=flat-square&logo=linux" />
  <img src="https://img.shields.io/github/license/nkbeast/PhishGuard?style=flat-square" />
  <img src="https://img.shields.io/github/stars/nkbeast/PhishGuard?style=flat-square" />
  <img src="https://img.shields.io/badge/status-terminal%20sniper-green?style=flat-square" />
</p>

---

![PhishGuard Banner](https://raw.githubusercontent.com/nkbeast/PhishGuard/main/banner.png)

---

## 🧠 What is PhishGuard?

**PhishGuard** is a terminal-based, zero-dependency reconnaissance tool that hunts for misconfigured domains with weak or missing **SPF** and **DMARC** records. It helps identify domains vulnerable to spoofing or phishing.

It performs bulk DNS analysis with intelligent logic for:

- ✅ DNS resolution check
- 📤 MX record validation against trusted providers
- ☀️ SPF strength evaluation (`~all`, `-all`, or missing)
- 🔐 DMARC policy enforcement (`p=none`, or missing)

---

## 🚀 Features

| Feature            | Description |
|--------------------|-------------|
| ⚡ Ultra-Light      | Pure Bash script — no Python or external dependencies |
| 📂 Bulk Mode        | Scan thousands of domains from a file |
| 🛡️ MX Trust Filter | Filters out domains using CDN/analytics MX (e.g., Akamai) |
| 🌐 SPF Analyzer     | Detects weak (`~all`) or missing SPF records |
| 🔥 DMARC Scanner    | Detects missing or weak (`p=none`) DMARC records |
| 📊 Severity Tags   | Classifies domains as P3 or P4 based on combined misconfigs |
| 📢 Verbose Mode     | Use `--vuln` to show only vulnerable domains |
| 🌍 Discord Webhook | Send results to a Discord channel via `-w <url>` |
| 📝 Save Results     | Save terminal output to a file with `-o <file>` |

---

## 🧨 Vulnerability Classes

| Severity | Description |
|----------|-------------|
| **P3**   | SPF is weak or missing **AND** DMARC is weak or missing |
| **P4**   | SPF is present but DMARC is **weak** (`p=none`) |

PhishGuard intelligently skips domains with non-legit mail services using a trusted MX provider list (e.g., Gmail, Outlook, Zoho, ProtonMail).

---

## 📦 Installation

```bash
git clone https://github.com/nkbeast/PhishGuard.git
cd PhishGuard
chmod +x phishguard.sh
```

## 📦 Usage
```
# Scan a single domain
./phishguard.sh -d example.com

# Scan domains from a list
./phishguard.sh -l domains.txt

# Show only vulnerable (P3/P4) domains
./phishguard.sh -l domains.txt --vuln

# Save results to a text file
./phishguard.sh -l domains.txt -o results.txt

# Send results to Discord webhook
./phishguard.sh -l domains.txt -w https://discord.com/api/webhooks/...

./phishguard.sh -l domains.txt --webhook https://discord.com/api/webhooks/...
```
