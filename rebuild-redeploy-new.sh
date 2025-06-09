# 1. Clean up the current deployment
juju remove-application ripgrep-operator --force
juju remove-machine 8 --force

# 2. Wait a few seconds and verify cleanup
juju status

# 3. Rebuild and deploy
cd ~/ripgrep-operator
charmcraft pack
juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm

# 4. Once deployed, let's check the logs specifically for the data-storage-attached hook
juju debug-log --replay --include unit-ripgrep-operator/0 | grep -i "data-storage-attached\|error\|failed\|exception" | tail -n 30