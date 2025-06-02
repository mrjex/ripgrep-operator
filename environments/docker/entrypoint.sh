#!/bin/bash

# Function to wait for snapd to be ready
wait_for_snapd() {
    echo "Waiting for snapd to be ready..."
    local max_attempts=30
    local attempt=1
    
    # Ensure snapd socket directory exists
    mkdir -p /run/snapd
    
    # Wait for dbus to be ready
    while ! dbus-send --system --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames >/dev/null 2>&1; do
        echo "Waiting for dbus..."
        sleep 1
    done
    
    # Start snapd service if not running
    if ! systemctl is-active snapd >/dev/null 2>&1; then
        echo "Starting snapd service..."
        systemctl start snapd.service snapd.socket
    fi
    
    while ! snap list >/dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            echo "Error: snapd failed to start after $max_attempts attempts"
            echo "Debugging information:"
            systemctl status snapd.service
            systemctl status snapd.socket
            ls -la /run/snapd
            journalctl -xe
            return 1
        fi
        echo "Attempt $attempt/$max_attempts: Waiting for snapd..."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo "Snapd is ready"
}

# Function to install and configure LXD
setup_lxd() {
    echo "Installing LXD..."
    # Ensure snap directory is properly mounted
    mkdir -p /snap
    
    # Install LXD
    snap install lxd || return 1
    
    echo "Installing Juju..."
    snap install juju --classic || return 1
    
    echo "Installing Charmcraft..."
    snap install charmcraft --classic || return 1
    
    echo "Initializing LXD..."
    lxd init --auto || return 1
}

# Function to setup systemd
setup_systemd() {
    echo "Setting up systemd..."
    
    # Mount necessary filesystems
    mount -t proc proc /proc
    mount -t sysfs sys /sys
    mount -t tmpfs tmpfs /run
    mkdir -p /run/lock
    
    # Start dbus
    mkdir -p /var/run/dbus
    dbus-daemon --system --fork
    
    # Start systemd
    if [ ! -d /run/systemd/system ]; then
        mkdir -p /run/systemd/system
    fi
}

# Main setup
main() {
    # Check if we're PID 1
    if [ $$ -eq 1 ]; then
        # If we're PID 1, we need to exec systemd
        echo "Starting systemd as PID 1..."
        exec /sbin/init
    else
        # Setup systemd
        setup_systemd
        
        # Wait for systemd to be ready
        while ! systemctl status >/dev/null 2>&1; do
            echo "Waiting for systemd..."
            sleep 1
        done
        
        # Wait for snapd with debugging
        if ! wait_for_snapd; then
            echo "Failed to initialize snapd"
            exit 1
        fi
        
        # Setup LXD and other tools with debugging
        if ! setup_lxd; then
            echo "Failed to setup LXD"
            systemctl status snapd.service
            journalctl -xe
            exit 1
        fi
        
        echo "Container initialization complete"
        
        # Keep container running
        exec "$@"
    fi
}

# Run main function with all arguments
main "$@"
