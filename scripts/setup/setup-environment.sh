##  SETUP ENVIRONMENT  ##
#
#   - Execute this inside the newly created Multipass (Ubuntu) VM
#     to setup all the necessary dependencies for the project. Note
#     that this script assumes you already can setup or interact within
#     Ubuntu 22.04 environments.



installTechnologies() {
    sudo snap install snapcraft --classic
    sudo snap install juju --classic
    sudo snap install charm --classic
    sudo snap install charmcraft --classic
    sudo snap install lxd
    sudo snap install ripgrep --classic
}


setupTechnologies() {
    # Add current user to the lxd group
    sudo usermod -aG lxd $USER

    sudo lxd init --auto
    sudo apt update
    sudo apt install -y snapd
    sudo snap install core
    sudo snap refresh core

    # Create a new storage pool if needed
    lxc storage create default dir

    # Create a network bridge if needed
    lxc network create lxdbr0
}


# These packages typically prompt a menu requiring manual confirmation
installManualPromptPackages() {
    sudo apt-get update

    sudo apt install python3-pip python3-venv python3-dev build-essential
    sudo apt install -y jq
}


setupJuju() {
    # Initialize Juju with LXD
    juju bootstrap localhost lxd-controller

    # Create a new model for development
    juju add-model development
}


##  MAIN  ##

set -e  # Exit on error
set -x  # Echo each command

sudo apt update
sudo apt install -y snapd

export PATH=$PATH:/snap/bin

installTechnologies
setupTechnologies

echo "COMPLETED SETUP (STEP 1/3)"

installManualPromptPackages

echo "COMPLETED SETUP (STEP 2/3)"

setupJuju

echo "COMPLETED SETUP (STEP 3/3)"
