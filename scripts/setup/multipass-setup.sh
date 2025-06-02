#!/bin/bash

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/common/utils.sh"
source "${SCRIPT_DIR}/common/config.sh"

# Check if Multipass is installed
check_multipass() {
    if ! command_exists multipass; then
        error "Multipass is not installed. Please install Multipass first."
    fi
}

# Create and configure Multipass VM
setup_multipass_vm() {
    # Check if VM already exists
    if multipass info "${MULTIPASS_VM_NAME}" >/dev/null 2>&1; then
        warn "VM ${MULTIPASS_VM_NAME} already exists. Stopping and deleting..."
        multipass stop "${MULTIPASS_VM_NAME}"
        multipass delete "${MULTIPASS_VM_NAME}"
        multipass purge
    fi
    
    echo "Creating Multipass VM..."
    if ! multipass launch --name "${MULTIPASS_VM_NAME}" \
        --cpus "${MULTIPASS_CPU}" \
        --memory "${MULTIPASS_MEMORY}" \
        --disk "${MULTIPASS_DISK}" \
        --cloud-init "${MULTIPASS_CLOUD_INIT}"; then
        error "Failed to create Multipass VM"
    fi
    
    # Mount project directory
    echo "Mounting project directory..."
    if ! multipass mount "${PROJECT_ROOT}" "${MULTIPASS_VM_NAME}:${MULTIPASS_DEV_PATH}"; then
        error "Failed to mount project directory"
    fi
    
    success "Multipass VM setup complete"
}

# Wait for cloud-init to complete
wait_for_cloud_init() {
    echo "Waiting for cloud-init to complete..."
    multipass exec "${MULTIPASS_VM_NAME}" -- cloud-init status --wait
    success "Cloud-init completed"
}

# Main setup function
main() {
    echo "Setting up Multipass development environment..."
    
    # Perform checks
    check_multipass
    
    # Setup Multipass VM
    setup_multipass_vm
    
    # Wait for initialization
    wait_for_cloud_init
    
    success "Multipass development environment setup complete!"
    echo "You can now access the development environment using:"
    echo "multipass shell ${MULTIPASS_VM_NAME}"
}

# Run main function
main "$@" 