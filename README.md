# 🌐 Network Optimius

**Network Optimius** is a lightweight, privacy-focused Linux tool written in **pure Bash** that automatically selects the **best DNS server for your network and location** based on real-time latency, packet loss, and jitter measurements.

It can run **manually or automatically** on a custom schedule (minutes, hours, days, weeks) and is **fully reversible**, restoring your system back to DHCP at any time.

---

##  Features

-  **Smart DNS selection**
  - Tests **router (ISP) DNS**
  - Tests public DNS providers (Cloudflare, Google, Quad9, etc.)
  - Chooses the best DNS using a weighted scoring algorithm

-  **Advanced network metrics**
  - Average latency (ms)
  - Packet loss (%)
  - Jitter (network stability)

-  **Automation**
  - Run once
  - Run every `30m`, `1h`, `1d`, `1w` (custom cron scheduling)

-  **Safe restore**
  - Reverts DNS settings back to **DHCP**
  - Removes cron jobs cleanly

-  **Privacy-first**
  - No tracking
  - No telemetry
  - No external services
  - 100% local execution

-  **Logging**
  - Full audit log stored in `/var/log/network-optimuis.log`

---

## Supported Systems

- Linux distributions using **NetworkManager**
  - Arch Linux / Manjaro
  - Ubuntu / Debian
  - Fedora
  - OpenSUSE

---

##  Requirements

- `bash`
- `iproute2`
- `networkmanager`
- `iputils` (ping)
- `bc`
- Root privileges (`sudo`)

---

##  Installation

### Arch Linux / Manjaro
```bash
sudo pacman -S --needed iproute2 networkmanager iputils bc
```

### Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y iproute2 network-manager iputils-ping bc
```

### Fedora
```bash
sudo dnf install -y iproute networkmanager iputils bc
```

### OpenSUSE
```bash
sudo zypper install -y iproute2 NetworkManager iputils bc
```

---

##  Usage

```bash
chmod +x noptimuis
sudo ./noptimuis
```

---

##  Automatic Mode Examples

| Input | Meaning |
|------|--------|
| `30m` | Run every 30 minutes |
| `1h`  | Run every hour |
| `1d`  | Run once per day |
| `1w`  | Run once per week |

---

## DNS Scoring Algorithm

```
score = latency + (packet_loss × 10) + (jitter × 2)
```

Lower score = better DNS.

---

##  Restore Original DNS

Restores:
- DHCP DNS
- Auto DNS
- Removes cron jobs

---

##  Security Notes

- Runs only on your local machine
- Does not modify router firmware
- Does not affect other devices
- Requires root only for DNS changes

---

##  Project Structure

```
Network-Optimius/
├── noptimuis
├── README.md
└── LICENSE
```

---

##  Author

**KarmsDev** 

---

## Tags 
#bash #linux #networking #dns #dns-optimizer #network-optimization #devops #sysadmin #automation
#cron #network-management #network-monitoring #network-tools #privacy #performance #bash-script

##  License

- GPL-3.0 license
