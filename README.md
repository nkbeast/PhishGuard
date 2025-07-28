<h1 align="center">🎯 PhishGuard</h1>

<p align="center">
  <b>DMARC Misconfiguration Sniper</b><br>
  Identify phishing-prone domains by scanning DNS, MX, and DMARC in bulk.<br>
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

**PhishGuard** is a terminal-based, zero-dependency phishing reconnaissance tool that hunts for misconfigured domains missing strict **DMARC** policies. It performs bulk checks for:

- DNS records
- MX records
- DMARC misconfigurations

With its minimalist but powerful Bash engine, it's perfect for bug bounty recon, domain asset evaluation, or phishing surface mapping.

---

## 🚀 Features

| Feature          | Description |
|------------------|-------------|
| ⚡ Ultra-Light    | Pure Bash, no Python or dependencies required |
| 📂 Bulk Mode      | Scan thousands of domains from a list |
| ✅ DNS/MX Check   | Verify DNS & MX presence before DMARC scan |
| 🔥 DMARC Sniper  | Detects "p=none" or missing DMARC records |
| 📄 HTML Report   | Auto-generate clean HTML report with `--html` |
| 📢 Verbose Logs  | Optional `-v` flag shows full output |
| 🧼 Clean Output   | Non-verbose mode shows **only vulnerable** |

---

## 📦 Installation

```bash
git clone https://github.com/nkbeast/PhishGuard.git
cd PhishGuard
chmod +x phishguard.sh
```

## 📦 Installation

```bash
./phishguard.sh -d example.com

./phishguard.sh -l domains.txt

./phishguard.sh -l domains.txt --html

./phishguard.sh -l domains.txt -v
```
