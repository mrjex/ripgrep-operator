# Development Environment Setup Guide

This guide provides detailed instructions for setting up your development environment for the ripgrep-operator charm. Choose the setup that best matches your operating system and preferences.

## Prerequisites

- Git installed
- Internet connection
- One of the following:
  - Docker Desktop (for Docker-based setup)
  - Multipass (for VM-based setup)
  - Linux with snap support (for native setup)

## Environment Options

### 1. Docker-based LXD Setup

Best for Windows/Mac users who:
- Are familiar with Docker
- Want minimal resource usage
- Need quick setup/teardown

[Detailed Docker Setup Instructions](docker-setup.md)

### 2. Multipass Setup

Best for Windows/Mac users who:
- Want a traditional Ubuntu experience
- Prefer VM-based development
- Need full system isolation

[Detailed Multipass Setup Instructions](multipass-setup.md)

### 3. Native LXD Setup

Best for Linux users who:
- Are running Ubuntu or another Linux distribution
- Want best performance
- Need direct system access

#### Native LXD Setup Steps

1. Install required snaps:
```bash
sudo snap install lxd
sudo snap install juju --classic
sudo snap install charmcraft --classic
```

2. Initialize LXD:
```bash
sudo lxd init --auto
```

3. Configure LXD networking:
```bash
sudo lxc network create lxdbr0
sudo lxc network attach-profile lxdbr0 default eth0
```

4. Verify setup:
```bash
lxc launch ubuntu:20.04 test-container
lxc exec test-container -- echo "LXD is working!"
lxc delete -f test-container
```

## Common Development Tasks

Regardless of your chosen environment, these commands work the same:

### Building the Charm
```bash
charmcraft pack
```

### Running Tests
```bash
tox run -e unit
```

### Deploying for Testing
```bash
juju deploy ./ripgrep-operator_ubuntu-22.04-amd64.charm
```

## Troubleshooting

### Common Issues

1. Network Connectivity
- Docker: Check Docker network settings
- Multipass: Verify VM network adapter
- Native LXD: Check LXD bridge configuration

2. Resource Issues
- Docker: Adjust Docker Desktop resources
- Multipass: Modify VM memory/CPU allocation
- Native LXD: Check system resources

3. Permission Issues
- Docker: Ensure proper group membership
- Multipass: Check user permissions
- Native LXD: Verify LXD group membership

### Getting Help

- File issues on GitHub
- Check existing documentation
- Join our community channels

## Best Practices

1. Environment Management
- Keep environments isolated
- Use version control
- Document custom configurations

2. Resource Usage
- Clean up unused containers
- Monitor system resources
- Use appropriate resource limits

3. Development Workflow
- Use consistent tooling
- Follow charm development guidelines
- Maintain test coverage

## Environment-Specific Notes

### Docker-based LXD
- Container persistence
- Network considerations
- Volume mounting

### Multipass
- VM snapshots
- Resource allocation
- Host integration

### Native LXD
- System requirements
- Security considerations
- Performance tuning

## Additional Resources

- [Juju Documentation](https://juju.is/docs)
- [LXD Documentation](https://linuxcontainers.org/lxd/docs/master/)
- [Charm Development Guide](https://juju.is/docs/sdk)
