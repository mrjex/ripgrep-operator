#!/bin/bash

# Function to wait for snapd to be ready
wait_for_snapd() {
    echo "Waiting for snapd to be ready..."
    while ! snap list >/dev/null 2>&1; do
        sleep 1
    done
    echo "Snapd is ready"
}

# Function to install and configure LXD
setup_lxd() {
    echo "Installing LXD..."
    snap install lxd || return 1
    
    echo "Installing Juju..."
    snap install juju --classic || return 1
    
    echo "Installing Charmcraft..."
    snap install charmcraft --classic || return 1
    
    echo "Initializing LXD..."
    lxd init --auto || return 1
}

# Main setup
main() {
    # Start systemd if it's not running
    if [ ! -d /run/systemd/system ]; then
        exec /lib/systemd/systemd
    fi

    # Wait for snapd
    wait_for_snapd

    # Setup LXD and other tools
    setup_lxd

    # Keep container running
    exec "$@"
}

# Run main function with all arguments
main "$@"
