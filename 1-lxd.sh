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
    
    # Remove existing network if it exists
    echo "Cleaning up existing network configuration..."
    lxc profile device remove default eth0 || true
    lxc network delete lxdbr0 || true
    
    # Create new network with specific settings
    echo "Creating new network..."
    lxc network create lxdbr0 \
        ipv4.address=10.10.10.1/24 \
        ipv4.nat=true \
        ipv4.dhcp=true \
        ipv4.dhcp.ranges=10.10.10.2-10.10.10.254 \
        dns.domain=lxd \
        dns.mode=managed \
        dns.nameservers=8.8.8.8,8.8.4.4 \
        ipv6.address=none

    # Add network to default profile
    echo "Configuring default profile..."
    lxc profile device add default eth0 nic nictype=bridged parent=lxdbr0 security.mac_filtering=false
    
    echo -e "${GREEN}Network setup complete - OK${NC}"
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
