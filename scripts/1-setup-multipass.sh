installPackages() {
    # 1. Install required snaps if not already installed
    sudo snap install ripgrep --classic
    sudo snap install charmcraft --classic
    sudo snap install juju --classic
    sudo snap install multipass --classic

    # 2. Install Python dependencies
    sudo apt install tox python3-pip
}

setupMultipass() {
    # Configure charmcraft to use multipass instead of LXD
    sudo snap set charmcraft provider=multipass

    # Launch a multipass instance for charmcraft if it doesn't exist
    if ! multipass list | grep -q "charm-dev"; then
        multipass launch --name charm-dev --memory 4G --disk 10G
    fi

    # Configure charmcraft to use this instance
    sudo snap connect charmcraft:multipass
}

initializeCharm() {
    # 3. Initialize charm project
    charmcraft init --profile machine --force --author="Joel Mattsson joel.mattsson@hotmail.se"
}

buildCharm() {
    # 4. Run unit tests
    # tox run -e unit

    # 5. Build the charm
    # Make sure we're using multipass
    sudo snap set charmcraft provider=multipass
    charmcraft pack
}

# 6. Deploy and test with Multipass
deployAndTest() {
    # Initialize Juju with Multipass
    juju bootstrap multipass multipass-controller

    # Create a test model
    juju add-model test

    # Deploy the charm
    juju deploy ./ripgrep-operator_ubuntu-22.04-amd64.charm

    # Wait for the deployment to complete
    echo "Waiting for deployment to complete..."
    juju status --watch 5s

    # Test a search once the deployment is ready
    juju run-action ripgrep-operator/0 search-pattern pattern="test"

    # Show final status
    juju status
}

# 7. Cleanup function (optional)
cleanup() {
    # Remove the Juju controller and all models
    juju destroy-controller multipass-controller --destroy-all-models --force

    # Stop and delete the Multipass VMs
    multipass stop charm-dev multipass-controller
    multipass delete charm-dev multipass-controller
    multipass purge
}

# Main execution flow
main() {
    # installPackages
    setupMultipass
    #initializeCharm
    #buildCharm
    # Uncomment the following line when ready to deploy
    # deployAndTest
}

# Run the script
main

