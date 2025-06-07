##  Set Up the Development Environment for Charm Operators  ##

# Install Multipass (if not on Ubuntu)
sudo snap install multipass

# Install Juju
sudo snap install juju --classic

# Install LXD
sudo snap install lxd
sudo lxd init --auto

# Initialize Juju with LXD
juju bootstrap localhost lxd-controller

# Create a new model for development
juju add-model development