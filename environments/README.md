# Development Environment Setup

This directory contains configuration files and setup scripts for different development environments. The ripgrep-operator charm can be developed using any of the following environments:

## Available Environments

### 1. Docker-based LXD (Windows/Mac)
- Uses Ubuntu container with systemd support
- Full LXD functionality through containerization
- Requires Docker Desktop
- Best for Windows/Mac users familiar with Docker
- See [Docker Setup Guide](../docs/docker-setup.md)

### 2. Multipass (Windows/Mac)
- Uses lightweight Ubuntu VM
- Native Ubuntu experience
- Requires Multipass installation
- Best for Windows/Mac users who want VM-like experience
- See [Multipass Setup Guide](../docs/multipass-setup.md)

### 3. Native LXD (Linux)
- Direct LXD installation on Linux
- Best performance
- Linux only
- See [Native LXD Setup](../docs/environments.md#native-lxd-setup)

## Quick Start

1. Choose your environment:
```bash
cd scripts
./setup-env.sh
```

2. Follow the prompts to select and configure your environment

## Directory Structure

```
environments/
├── docker/           # Docker-based LXD setup
│   ├── Dockerfile   # Ubuntu + systemd + LXD container
│   └── docker-compose.yml
├── multipass/        # Multipass VM setup
│   └── cloud-init.yaml
└── README.md        # This file
```


## Contributing

When adding new environment support:
1. Create a new directory under `environments/`
2. Add necessary configuration files
3. Create setup scripts in `scripts/setup/`
4. Update documentation in `docs/`
5. Update this README with new environment details