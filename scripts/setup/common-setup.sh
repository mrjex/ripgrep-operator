#!/bin/bash

# Source common utilities and configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/common/utils.sh"
source "${SCRIPT_DIR}/common/config.sh"

# Check system requirements
check_system_requirements() {
    echo "Checking system requirements..."
    
    # Check required tools
    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command_exists "$tool"; then
            error "$tool is not installed. Please install it first."
        fi
    done
    
    success "All required tools are installed"
}

# Setup Python virtual environment
setup_venv() {
    echo "Setting up Python virtual environment..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    source .venv/bin/activate
    
    # Install development requirements
    if [ -f "requirements-dev.txt" ]; then
        pip install -r requirements-dev.txt
    elif [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    else
        warn "No requirements file found"
    fi
    
    success "Python virtual environment setup complete"
}

# Setup git hooks
setup_git_hooks() {
    echo "Setting up git hooks..."
    
    # Initialize git if not already initialized
    if [ ! -d ".git" ]; then
        git init
    fi
    
    # Setup pre-commit hook for linting
    if [ ! -f ".git/hooks/pre-commit" ]; then
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run linting before commit
source .venv/bin/activate
python -m flake8 .
EOF
        chmod +x .git/hooks/pre-commit
    fi
    
    success "Git hooks setup complete"
}

# Main setup function
main() {
    echo "Running common setup steps..."
    
    # Change to project root
    cd "${PROJECT_ROOT}" || error "Could not change to project root directory"
    
    # Run setup steps
    check_system_requirements
    setup_venv
    setup_git_hooks
    
    success "Common setup complete!"
}

# Run main function
main "$@" 