# KoukeNeko Package Repository

Personal package repository for Debian/Ubuntu (APT) and RHEL/CentOS/Fedora (RPM).

## Quick Install

### Debian / Ubuntu

```bash
curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash
sudo apt install hashi
```

### RHEL / CentOS / Fedora

```bash
curl -fsSL https://koukeneko.github.io/pkg-repo/rpm/install.sh | sudo bash
sudo dnf install hashi
```

## Available Packages

| Package | Description | Architectures |
|---------|-------------|---------------|
| `hashi` | Hashi Server Management Dashboard | amd64, arm64 |

## Version Channels

版本號自動區分 stable/beta/dev：

| Channel | Version Format | Example |
|---------|----------------|---------|
| stable | `X.Y.Z` | `0.0.0.12` |
| beta | `X.Y.Z~beta` | `0.0.0.12~beta` |
| dev | `X.Y.Z~dev.DATE` | `0.0.0.1~dev.20241211` |

```bash
# 查看可用版本
apt-cache policy hashi

# 安裝特定版本
sudo apt install hashi=0.0.0.12~beta
```
