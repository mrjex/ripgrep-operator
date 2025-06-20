#!/bin/bash

# Directory: ~/ripgrep-operator

# Import functions from get-snap-packages.sh
source ./get-snap-packages.sh

# Clean up previous deployment
cleanPreviousDeployment() {
    PREV_REVISION=${1}

    juju remove-application ripgrep-operator --force
    juju remove-machine ${PREV_REVISION} --force
}

# Deploy new version
deployCharm() {
    # sudo charmcraft clean
    sudo charmcraft pack
    # juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm
    # juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap
    juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap
}

# Monitor status
monitorCharmStatus() {
    juju status --watch 1s
}

##  MAIN  ##

# juju status # Check current revision number

cleanPreviousDeployment ${1}

echo "Getting latest CLI snap package..."
getPrivateCLI

echo "Snap package:"
ls ~/ripgrep-operator | grep .snap

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