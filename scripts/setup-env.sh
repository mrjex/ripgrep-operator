#!/bin/bash

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common/utils.sh"
source "${SCRIPT_DIR}/common/config.sh"

# Print usage information
print_usage() {
    echo "Usage: $0 [docker|multipass]"
    echo
    echo "Options:"
    echo "  docker    Setup Docker-based development environment"
    echo "  multipass Setup Multipass-based development environment"
    echo
    echo "If no option is provided, you will be prompted to choose."
}

# Get environment choice from user
get_environment_choice() {
    if [ $# -eq 1 ]; then
        case "$1" in
            docker|multipass)
                echo "$1"
                return
                ;;
            *)
                error "Invalid environment: $1"
                ;;
        esac
    fi
    
    echo "Please choose your development environment:"
    echo "1) Docker (recommended for most users)"
    echo "2) Multipass (recommended for Windows users with WSL2 networking issues)"
    echo
    read -p "Enter your choice (1 or 2): " choice
    
    case "$choice" in
        1) echo "docker" ;;
        2) echo "multipass" ;;
        *) error "Invalid choice: $choice" ;;
    esac
}

# Main setup function
main() {
    # Print banner
    echo "========================================="
    echo "Ripgrep Operator Development Environment Setup"
    echo "========================================="
    echo
    
    # Get environment choice
    env_choice=$(get_environment_choice "$@")
    
    # Run common setup first
    "${SCRIPT_DIR}/setup/common-setup.sh"
    
    # Run environment-specific setup
    case "$env_choice" in
        docker)
            "${SCRIPT_DIR}/setup/docker-setup.sh"
            ;;
        multipass)
            "${SCRIPT_DIR}/setup/multipass-setup.sh"
            ;;
    esac
    
    success "Development environment setup complete!"
    echo
    echo "Next steps:"
    echo "1. Review the documentation in docs/ directory"
    echo "2. Start developing your charm!"
}

# Show usage if --help flag is provided
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_usage
    exit 0
fi

# Run main function
main "$@"
