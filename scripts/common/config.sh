#!/bin/bash

# Project configuration
PROJECT_NAME="ripgrep-operator"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Docker configuration
DOCKER_IMAGE_NAME="ripgrep-dev"
DOCKER_CONTAINER_NAME="ripgrep-dev"
DOCKER_COMPOSE_FILE="${PROJECT_ROOT}/environments/docker/docker-compose.yml"

# Multipass configuration
MULTIPASS_VM_NAME="ripgrep-dev"
MULTIPASS_CPU="2"
MULTIPASS_MEMORY="4G"
MULTIPASS_DISK="20G"
MULTIPASS_CLOUD_INIT="${PROJECT_ROOT}/environments/multipass/cloud-init.yaml"

# Development paths
DEV_PATH="/workspace/ripgrep-operator"
MULTIPASS_DEV_PATH="/home/ubuntu/ripgrep-operator"

# Required tools
REQUIRED_TOOLS=(
    "git"
    "python3"
    "pip3"
)

# Required snaps
REQUIRED_SNAPS=(
    "lxd"
    "juju --classic"
    "charmcraft --classic"
) 