

# Directory: ~/ripgrep-operator






# Clean up previous deployment


cleanPreviousDeployment() {
    PREV_REVISION=${1}

    juju remove-application ripgrep-operator --force
    juju remove-machine ${PREV_REVISION} --force
}


# Deploy new version

deployCharm() {
    charmcraft pack
    juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm
}

# Monitor status

monitorCharmStatus() {
    juju status --watch 1s
}



##  MAIN  ##

# juju status # Check current revision number

cleanPreviousDeployment 15

echo "Deploy new version"

deployCharm

echo "Monitor status"

monitorCharmStatus


# 1. Clean up the current deployment
# juju remove-application ripgrep-operator --force
# juju remove-machine 8 --force

# 2. Wait a few seconds and verify cleanup
# juju status

# 3. Rebuild and deploy
# cd ~/ripgrep-operator
# charmcraft pack
#juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm

# 4. Once deployed, let's check the logs specifically for the data-storage-attached hook
# juju debug-log --replay --include unit-ripgrep-operator/0 | grep -i "data-storage-attached\|error\|failed\|exception" | tail -n 30