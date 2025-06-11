# Ripgrep Operator

[![Charmhub](https://img.shields.io/badge/Charmhub-ripgrep--operator-blue)](https://charmhub.io)
[![Snapcraft](https://img.shields.io/badge/Snapcraft-Store-green)](https://snapcraft.io)
[![Juju](https://img.shields.io/badge/Juju-2.9+-purple)](https://juju.is/)
[![LXD](https://img.shields.io/badge/LXD-5.0+-orange)](https://linuxcontainers.org/lxd)
[![Multipass](https://img.shields.io/badge/Multipass-1.12+-lightblue)](https://multipass.run)

> A Juju charm that provides ripgrep functionality as a service, enabling remote text search capabilities across different architectures and deployment scenarios.



## Architecture

- **Picture here**


- *Brief explanation here...*

- This charm operator integrates into a larger system..
- Multiple components..
- Host OS, Multipass VM, Juju Controller orchestrator, LXD Containers, Charm operators, Snap packages, ...




## Quick Start

1. Setup Ubuntu environment

2. Run `./scripts/setup/setup-environment.sh`


Depending on your setup, you might need to manage a separate directory (a clone of the mounted one) in the virtual machine. This is to bypass strict Linux permissions.


2.1 Run `./scripts/dev-lifecycle/sync-dir.sh`


3. Run `./scripts/dev-lifecycle`




## Deployment


- Juju, LXD, Charm


- Suite of tests categorized by the Charm's defined actions in *actions.yaml*

- `scripts/tests/charm-snap-tests.sh`

- - `scripts/tests/search-pattern-tests.sh`



## Further Development


- You will find the script `scripts/dev-lifecycle/juju-ssh-debug.sh` very useful

- `scripts/dev-lifecycle/get-snap-packages.sh` --> Gets the snap packages of correspondig system components being standalone CLIs




## Business Value

The ripgrep operator wraps the high-performance ripgrep search tool in a Juju charm, making it remotely deployable, observable, and integratable with other cloud-native applications through standardized interfaces. By providing a cloud-native interface to ripgrep's powerful search capabilities, it enables automated, scalable text analysis across distributed systems, which is particularly valuable when combined with other tools (like your Debian package analyzer) for comprehensive system analysis. The operator pattern allows for consistent deployment, monitoring, and integration across different architectures and cloud environments, making it easier to incorporate powerful text search capabilities into larger automated workflows.




## Features

- Cloud-native wrapper for ripgrep search functionality
- Remote deployment and management through Juju
- Multi-architecture support through LXD
- Standardized interfaces for search pipeline integration
- Observable and scalable text search capabilities



## Inspirational Sources


### Open Source Operators

**Primary Sources:**

- [Postgresql Operator](https://github.com/canonical/postgresql-operator/tree/main?tab=security-ov-file)
- [Hydra Operator](https://github.com/canonical/hydra-operator)

**Secondary Sources:**

- [Prometheus Operator](https://github.com/canonical/prometheus-k8s-operator/tree/main)

**Other Sources:**

- [Charm Unit Tests](https://ops.readthedocs.io/en/latest/howto/write-unit-tests-for-a-charm.html)





---

Developed by Joel Mattsson