# 3. Initialize charm project
charmcraft init --profile machine --force --author="Your_Name Your_Email"

# 4. Install required snaps if not already installed
sudo snap install ripgrep --classic
sudo snap install charmcraft --classic
sudo snap install juju --classic
sudo snap install multipass

sudo apt install tox

# 5. Create LXD container for testing (if not already done)
lxd init --auto


#6. Run tests
tox run -e unit


# 7. After all files are created, build the charm
charmcraft pack




# 8. Deploy and test
deployAndTest() {
    # Create a test model
    juju add-model test

    # Deploy the charm
    juju deploy ./ripgrep-operator_ubuntu-22.04-amd64.charm

    # Test a search
    juju run-action ripgrep-operator/0 search-pattern pattern="test"
}