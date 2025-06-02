# Multipass Setup Guide

This guide explains how to set up a development environment for the ripgrep-operator charm using Multipass.

## Prerequisites

1. Multipass installed
   - [Windows Installation](https://multipass.run/docs/installing-on-windows)
   - [macOS Installation](https://multipass.run/docs/installing-on-macos)

2. Git installed
3. Text editor or IDE of your choice

## Setup Steps

### 1. Install Multipass

Windows:
```powershell
# Using winget
winget install Canonical.Multipass
```

macOS:
```bash
# Using homebrew
brew install --cask multipass
```

### 2. Configure Development Environment

1. Launch development VM:
```bash
cd scripts
./setup-env.sh
# Select option 2 for Multipass setup
```

This will:
- Create a new Ubuntu VM
- Install required packages
- Configure LXD
- Set up development environment

### 3. Environment Details

The Multipass setup provides:
- Ubuntu 22.04 LTS
- 4GB RAM (configurable)
- 20GB disk space
- Proper networking
- Shared folders support


## Usage

### Accessing the VM

```bash
multipass shell charm-dev
```

### Building the Charm

```bash
cd ripgrep-operator
charmcraft pack
```

### Running Tests

```bash
tox run -e unit
```


## Resource Management

### Modify VM Resources

```bash
# Stop VM
multipass stop charm-dev

# Adjust resources
multipass set local.charm-dev.cpus=4
multipass set local.charm-dev.memory=8G

# Start VM
multipass start charm-dev
```

### Storage Management

```bash
# Add storage
multipass mount /additional/storage charm-dev:/mnt/extra

# Check disk usage
multipass info charm-dev
```

## Troubleshooting

### Common Issues

1. VM fails to start
```bash
multipass stop charm-dev
multipass start charm-dev
```

2. Network connectivity
```bash
# Check network from VM
multipass exec charm-dev -- ping ubuntu.com
```

3. Resource issues
```bash
# Check VM status
multipass info charm-dev
```

### Logs

- Multipass logs: `multipass get local.charm-dev.log`
- System logs: `multipass exec charm-dev -- journalctl`
- LXD logs: `multipass exec charm-dev -- journalctl -u lxd`


## Cleanup

To remove the development environment:

```bash
# Stop VM
multipass stop charm-dev

# Delete VM
multipass delete charm-dev

# Purge deleted VMs
multipass purge

# Remove Multipass (optional)
# Windows: Use Apps & Features
# macOS: brew uninstall --cask multipass
```
