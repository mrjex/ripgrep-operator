# Ripgrep Operator

[![Charmhub](https://img.shields.io/badge/Charmhub-ripgrep--operator-blue)](https://charmhub.io)
[![Snapcraft](https://img.shields.io/badge/Snapcraft-Store-green)](https://snapcraft.io)
[![Juju](https://img.shields.io/badge/Juju-2.9+-purple)](https://juju.is/)
[![LXD](https://img.shields.io/badge/LXD-5.0+-orange)](https://linuxcontainers.org/lxd)
[![Multipass](https://img.shields.io/badge/Multipass-1.12+-lightblue)](https://multipass.run)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-pending-yellow)](https://github.com/joel0/ripgrep-operator/actions)

> A Juju charm that provides ripgrep functionality as a service, enabling remote text search capabilities across different architectures and deployment scenarios.

## Features

- Cloud-native wrapper for ripgrep search functionality
- Remote deployment and management through Juju
- Multi-architecture support through LXD
- Standardized interfaces for search pipeline integration
- Observable and scalable text search capabilities

## Quick Start

```bash
# Deploy the charm
juju deploy ripgrep-operator

# Run a search
juju run-action ripgrep-operator/0 search-pattern pattern="search_term"
```

## Documentation

- [Interface Documentation](docs/interfaces.md)
- [Actions Documentation](docs/actions.md)
- [Deployment Guide](docs/deployment.md)

## Development

```bash
# Setup development environment
./scripts/setup.sh

# Run tests
./scripts/test-multi-arch.sh
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

Ripgrep (`rg`) is a fast command-line search tool, like `grep`, but more efficient for recursive searches. It's commonly installed as a standalone binary or via package managers like `apt`, `brew`, or `snap`.

In essence, this project uses the [Ripgrep Snap Package](https://snapcraft.io/ripgrep) as a baseline and extends it into a standalone deployed and orchestrated Charm component on Juju, tailored for a wider range of use cases.



## Business Value

The ripgrep operator wraps the high-performance ripgrep search tool in a Juju charm, making it remotely deployable, observable, and integratable with other cloud-native applications through standardized interfaces. By providing a cloud-native interface to ripgrep's powerful search capabilities, it enables automated, scalable text analysis across distributed systems, which is particularly valuable when combined with other tools (like your Debian package analyzer) for comprehensive system analysis. The operator pattern allows for consistent deployment, monitoring, and integration across different architectures and cloud environments, making it easier to incorporate powerful text search capabilities into larger automated workflows.



## Inspirational Sources


### Open Source Operators

**Primary Sources:**

- [Postgresql Operator](https://github.com/canonical/postgresql-operator/tree/main?tab=security-ov-file)
- [Hydra Operator](https://github.com/canonical/hydra-operator)

**Secondary Sources:**

- [Prometheus Operator](https://github.com/canonical/prometheus-k8s-operator/tree/main)

**Other Sources:**

- [Charm Unit Tests](https://ops.readthedocs.io/en/latest/howto/write-unit-tests-for-a-charm.html)


### Technologies


- LXD

- Juju

- Charm / Charmcraft
- Charmhub

- Snap / Snapcraft
- Snapstore




---

Developed by Joel Mattsson