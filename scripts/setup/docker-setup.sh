#!/bin/bash

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/common/utils.sh"
source "${SCRIPT_DIR}/common/config.sh"

# Check if Docker is installed
check_docker() {
    if ! command_exists docker; then
        error "Docker is not installed. Please install Docker first."
    fi
    if ! command_exists docker-compose; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    }
}

# Check if Docker daemon is running
check_docker_daemon() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running. Please start Docker daemon first."
    fi
}

# Build and start the development container
setup_dev_container() {
    cd "${PROJECT_ROOT}/environments/docker" || error "Could not find Docker environment directory"
    
    echo "Building development container..."
    if ! docker-compose build; then
        error "Failed to build development container"
    fi
    
    echo "Starting development container..."
    if ! docker-compose up -d; then
        error "Failed to start development container"
    fi
    
    success "Development container is up and running"
}

# Main setup function
main() {
    echo "Setting up Docker development environment..."
    
    # Perform checks
    check_docker
    check_docker_daemon
    
    # Setup development container
    setup_dev_container
    
    success "Docker development environment setup complete!"
    echo "You can now access the development environment using:"
    echo "docker exec -it ${DOCKER_CONTAINER_NAME} bash"
}

# Run main function
main "$@" 