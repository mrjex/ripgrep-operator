#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in WSL2
check_wsl() {
    echo -e "${YELLOW}Checking WSL environment...${NC}"
    if ! grep -q "microsoft" /proc/version; then
        echo -e "${RED}This script is designed for WSL2. Please run it in WSL2.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Running in WSL2 - OK${NC}"
}

# Check LXD installation
check_lxd() {
    echo -e "${YELLOW}Checking LXD installation...${NC}"
    if ! command -v lxd >/dev/null 2>&1; then
        echo -e "${RED}LXD is not installed. Installing...${NC}"
        sudo snap install lxd
    fi
    echo -e "${GREEN}LXD is installed - OK${NC}"
}

# Initialize LXD if not already initialized
init_lxd() {
    echo -e "${YELLOW}Initializing LXD...${NC}"
    if ! lxc profile list >/dev/null 2>&1; then
        lxd init --auto
        echo -e "${GREEN}LXD initialized - OK${NC}"
    else
        echo -e "${GREEN}LXD already initialized - OK${NC}"
    fi
}

# Configure network settings
setup_network() {
    echo -e "${YELLOW}Setting up LXD network...${NC}"
    
    # Enable IP forwarding
    echo "Enabling IP forwarding..."
    sudo sysctl -w net.ipv4.ip_forward=1
    
    # Load bridge module
    echo "Loading bridge module..."
    sudo modprobe bridge
    sudo modprobe br_netfilter
    
    # Enable bridge-nf-call-iptables
    echo "Configuring bridge networking..."
    sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
    
    # Remove existing network if it exists
    echo "Cleaning up existing network configuration..."
    lxc profile device remove default eth0 2>/dev/null || true
    lxc network delete lxdbr0 2>/dev/null || true
    
    # Get WSL DNS server
    WSL_DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -n 1)
    echo "WSL DNS server: ${WSL_DNS}"
    
    # First create network with basic settings
    echo "Creating network with basic settings..."
    if ! lxc network create lxdbr0 \
        ipv4.address=10.10.10.1/24 \
        ipv4.nat=true \
        ipv4.dhcp=true \
        ipv4.dhcp.ranges=10.10.10.2-10.10.10.254 \
        ipv4.firewall=true \
        dns.mode=managed \
        dns.domain=lxd \
        ipv6.address=none \
        ipv6.nat=false \
        dns.nameservers="${WSL_DNS}" \
        raw.dnsmasq="server=${WSL_DNS}
dhcp-authoritative
dhcp-option=3,10.10.10.1
dhcp-option=6,${WSL_DNS}
log-queries
log-dhcp"; then
        echo -e "${RED}Failed to create basic network${NC}"
        return 1
    fi

    # Reset default profile
    echo "Resetting default profile..."
    lxc profile create default 2>/dev/null || true
    
    # Add network to default profile
    echo "Adding network to default profile..."
    lxc profile device add default eth0 nic \
        nictype=bridged \
        parent=lxdbr0 \
        name=eth0

    # Ensure bridge interface is up and configured
    echo "Ensuring bridge interface is up..."
    sudo ip link set lxdbr0 up
    sudo ip link set dev lxdbr0 mtu 1500
    sudo ip addr add 10.10.10.1/24 dev lxdbr0 2>/dev/null || true
    
    # Configure iptables
    echo "Configuring iptables..."
    sudo iptables -I FORWARD -i lxdbr0 -j ACCEPT
    sudo iptables -I FORWARD -o lxdbr0 -j ACCEPT
    sudo iptables -t nat -I POSTROUTING -s 10.10.10.0/24 ! -d 10.10.10.0/24 -j MASQUERADE

    # Wait for interface to come up
    echo "Waiting for interface to stabilize..."
    sleep 5

    # Create a test container to force bridge activation
    echo "Creating test container to activate bridge..."
    lxc launch ubuntu:20.04 test-bridge-activation
    sleep 10
    lxc delete -f test-bridge-activation

    # Verify network creation
    echo -e "\nVerifying network configuration:"
    if ! lxc network show lxdbr0; then
        echo -e "${RED}Failed to verify network configuration${NC}"
        return 1
    fi
    
    # Test network status
    echo -e "\nChecking network status:"
    if ! lxc network list | grep lxdbr0; then
        echo -e "${RED}Network not found in network list${NC}"
        return 1
    fi
    
    # Check bridge interface status
    echo -e "\n${YELLOW}Bridge Interface Status:${NC}"
    ip link show lxdbr0
    ip addr show lxdbr0
    
    echo -e "${GREEN}Network setup complete - OK${NC}"
    
    # Show current WSL network interface for debugging
    echo -e "\n${YELLOW}WSL Network Interface:${NC}"
    ip addr show eth0

    # Show DNS configuration
    echo -e "\n${YELLOW}DNS Configuration:${NC}"
    cat /etc/resolv.conf

    # Show dnsmasq configuration
    echo -e "\n${YELLOW}DNSMasq Configuration:${NC}"
    lxc network get lxdbr0 raw.dnsmasq

    # Show routing table
    echo -e "\n${YELLOW}Routing Table:${NC}"
    ip route

    # Show iptables NAT rules
    echo -e "\n${YELLOW}IPTables NAT Rules:${NC}"
    sudo iptables -t nat -L POSTROUTING -n -v

    # Verify bridge forwarding is enabled
    echo -e "\n${YELLOW}Bridge Forwarding Status:${NC}"
    sysctl net.bridge.bridge-nf-call-iptables
    sysctl net.ipv4.ip_forward

    # Final connectivity test
    echo -e "\n${YELLOW}Testing bridge connectivity:${NC}"
    ping -c 1 -W 1 10.10.10.1
}

# Test container networking
test_networking() {
    echo -e "${YELLOW}Testing container networking...${NC}"
    
    # Launch test container
    echo "Launching test container..."
    lxc launch ubuntu:20.04 test-container
    sleep 10 # Wait for container to fully start
    
    # Check container status
    echo "Checking container status..."
    lxc list
    
    # Test internal networking
    echo "Testing internal networking..."
    lxc exec test-container -- ip a
    
    # Test external connectivity
    echo "Testing external connectivity..."
    lxc exec test-container -- ping -c 4 8.8.8.8
    
    # Test DNS resolution
    echo "Testing DNS resolution..."
    lxc exec test-container -- ping -c 4 ubuntu.com
    
    # Cleanup test container
    echo "Cleaning up test container..."
    lxc delete -f test-container
}

# Verify WSL networking
check_wsl_networking() {
    echo -e "${YELLOW}Checking WSL networking...${NC}"
    
    # Check WSL network interface
    echo "WSL network interface:"
    ip addr show eth0
    
    # Check routing
    echo -e "\nRouting table:"
    ip route
    
    # Check DNS resolution
    echo -e "\nDNS configuration:"
    cat /etc/resolv.conf
    
    # Test host connectivity
    echo -e "\nTesting host connectivity:"
    ping -c 4 8.8.8.8
}

# Verify LXD service status
check_lxd_status() {
    echo -e "${YELLOW}Checking LXD service status...${NC}"
    sudo snap services lxd
    echo -e "\nLXD version:"
    lxd --version
}

# Main menu
show_menu() {
    echo -e "\n${YELLOW}LXD Management Menu${NC}"
    echo "1. Check WSL environment"
    echo "2. Initialize/Check LXD"
    echo "3. Setup network"
    echo "4. Test container networking"
    echo "5. Check WSL networking"
    echo "6. Check LXD status"
    echo "7. Run all checks"
    echo "8. Exit"
}

# Main execution
main() {
    while true; do
        show_menu
        read -p "Select an option: " choice
        case $choice in
            1) check_wsl ;;
            2) check_lxd && init_lxd ;;
            3) setup_network ;;
            4) test_networking ;;
            5) check_wsl_networking ;;
            6) check_lxd_status ;;
            7)
                check_wsl
                check_lxd
                init_lxd
                setup_network
                check_wsl_networking
                check_lxd_status
                test_networking
                ;;
            8) exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
}

# Run main function
main
