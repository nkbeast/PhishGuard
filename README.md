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

**PhishGuard** is a terminal-based, zero-dependency phishing reconnaissance tool that hunts for misconfigured domains missing strict **SPF** and **DMARC** policies. It performs bulk checks for:

- ✅ DNS records
- 📤 MX (Mail Exchange) record trust validation
- ☀️ SPF record strength (`-all`, `~all`, or missing)
- 🔐 DMARC policy enforcement (`p=none`, missing, etc.)

With its minimalist but powerful Bash engine, it's perfect for bug bounty recon, domain asset evaluation, or phishing surface mapping.

---

## 🚀 Features

| Feature            | Description |
|--------------------|-------------|
| ⚡ Ultra-Light      | Pure Bash, no Python or dependencies required |
| 📂 Bulk Mode        | Scan thousands of domains from a list |
| 🛡️ MX Trust Filter | Detect and skip non-legitimate MX services (e.g., Akamai/CDN) |
| ✅ DNS/MX Check     | Verify DNS & MX presence before SPF/DMARC scan |
| 🌐 SPF Scanner     | Detect weak (`~all`) or missing SPF configs |
| 🔥 DMARC Sniper    | Detect "p=none" or missing DMARC records |
| 📊 Classification  | Outputs P3 and P4 severity based on real misconfiguration logic |
| 📄 HTML Report     | Auto-generate clean HTML report with `--html` |
| 📢 Verbose Logs    | Optional `-v` flag shows full output |
| 🧼 Clean Output     | Non-verbose mode shows **only vulnerable** |
| 🌍 Webhook Support | Push results to Discord using `--webhook <url>` |
| 📝 Save to File    | Save results to plain `.txt` using `--output <file>` |

---

## 🎯 Vulnerability Classes

| Severity | Condition |
|----------|-----------|
| **P3**   | SPF is weak/missing **AND** DMARC is weak/missing |
| **P4**   | SPF is present but DMARC is **weak** (`p=none`) |

PhishGuard intelligently skips domains using CDN/analytics MX (e.g., Akamai, Adobe) by validating against a trusted mail service list.

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

# Scan domains from file
./phishguard.sh -l domains.txt

# Verbose output for full detail
./phishguard.sh -l domains.txt -v

# Generate HTML report
./phishguard.sh -l domains.txt --html

# Include SPF misconfig check
./phishguard.sh -l domains.txt -spf

# Save to file
./phishguard.sh -l domains.txt --output results.txt

# Push to Discord
./phishguard.sh -l domains.txt --webhook https://discord.com/api/webhooks/...
```
