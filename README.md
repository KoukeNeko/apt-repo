# KoukeNeko Package Repository

Personal package repository for Debian/Ubuntu (APT) and RHEL/CentOS/Fedora (RPM).

## Quick Install

### Debian / Ubuntu

```bash
curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash

# Install packages
sudo apt install hashi        # stable
sudo apt install hashi-beta   # beta
sudo apt install hashi-dev    # dev
```

### RHEL / CentOS / Fedora

```bash
curl -fsSL https://koukeneko.github.io/pkg-repo/rpm/install.sh | sudo bash
sudo dnf install hashi
```

## Available Packages

| Package | Channel | Description |
|---------|---------|-------------|
| `hashi` | stable | Production release |
| `hashi-beta` | beta | Pre-release testing |
| `hashi-dev` | dev | Development builds |

All packages support: `amd64`, `arm64`
