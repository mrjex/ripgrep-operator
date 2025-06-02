# Docker-based LXD Setup Guide

This guide explains how to set up a development environment for the ripgrep-operator charm using Docker with Ubuntu and LXD.

## Prerequisites

1. Docker Desktop installed and running
   - [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)

2. Git installed
3. WSL2 (for Windows users)

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/mrjex/ripgrep-operator.git
cd ripgrep-operator
```

### 2. Configure Docker Environment

1. Start Docker Desktop with the following requirements:
   - At least 4GB RAM allocated
   - At least 2 CPU cores
   - At least 20GB disk space

2. Run the setup script:
```bash
cd scripts
./setup-env.sh
# Select option 1 for Docker-based setup
```

### 3. Environment Details

The Docker setup provides:
- Ubuntu 22.04 base image
- Systemd support
- LXD pre-configured
- Proper networking setup
- Volume mounting for development

## Container Structure

```
Ubuntu Container
├── Systemd (PID 1)
├── LXD
│   └── Nested containers
├── Snap
│   ├── LXD
│   ├── Juju
│   └── Charmcraft
└── Mounted Volumes
    └── /workspace/ripgrep-operator
```

## Usage

### Starting Development Environment

```bash
cd environments/docker
docker-compose up -d
```

### Accessing the Environment

```bash
docker exec -it ripgrep-dev bash
```

### Building the Charm

```bash
cd /workspace/ripgrep-operator
charmcraft pack
```

### Running Tests

```bash
tox run -e unit
```

## Networking

The Docker environment sets up:
- Bridge network for container communication
- NAT for external access
- DNS configuration for name resolution

## Volume Mounting

Your local repository is mounted at `/workspace/ripgrep-operator` in the container, allowing:
- Direct file editing from your host
- IDE integration
- Version control from host

## Troubleshooting

### Common Issues

1. Container fails to start
```bash
# Check systemd status
docker exec ripgrep-dev systemctl status
```

2. LXD initialization fails
```bash
# Check LXD status
docker exec ripgrep-dev lxc info
```

3. Network issues
```bash
# Check network setup
docker exec ripgrep-dev lxc network list
```

### Logs

- Container logs: `docker logs ripgrep-dev`
- LXD logs: `docker exec ripgrep-dev journalctl -u lxd`
- System logs: `docker exec ripgrep-dev journalctl`


## Cleanup

To remove the development environment:

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (optional)
docker-compose down -v

# Full cleanup (optional)
docker system prune -a
```
