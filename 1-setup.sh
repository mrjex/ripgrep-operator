# 3. Initialize charm project
charmcraft init --profile machine

# 4. Install required snaps if not already installed
sudo snap install ripgrep --classic
sudo snap install charmcraft --classic
sudo snap install juju --classic
sudo snap install multipass

# 5. Create LXD container for testing (if not already done)
lxd init --auto

# 6. After all files are created, build the charm
charmcraft pack