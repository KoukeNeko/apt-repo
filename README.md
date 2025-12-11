# KoukeNeko Package Repository

Personal package repository for Debian/Ubuntu (APT) and RHEL/CentOS/Fedora (RPM).

## Quick Install

### Debian / Ubuntu

```bash
# Stable (recommended)
curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash

# Beta
curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash -s beta

# Dev
curl -fsSL https://koukeneko.github.io/pkg-repo/apt/install.sh | sudo bash -s dev

# Then install
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

## Suites

| Suite | Description |
|-------|-------------|
| `stable` | Production releases (default) |
| `beta` | Pre-release testing |
| `dev` | Development builds |
