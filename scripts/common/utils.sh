#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print an error message and exit
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Print a success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Print a warning message
warn() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on Windows
is_windows() {
    [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]] || [[ "$(uname -s)" == *"CYGWIN"* ]]
}

# Check if running in WSL
is_wsl() {
    [[ -f /proc/version ]] && grep -q "Microsoft" /proc/version
}

# Wait for a service to be ready
wait_for_service() {
    local service_name="$1"
    local max_attempts="${2:-30}"
    local attempt=1

    while ! systemctl is-active --quiet "$service_name"; do
        if [ $attempt -ge $max_attempts ]; then
            error "Service $service_name failed to start after $max_attempts attempts"
        fi
        echo "Waiting for $service_name to start (attempt $attempt/$max_attempts)..."
        sleep 2
        ((attempt++))
    done
    success "$service_name is running"
} 