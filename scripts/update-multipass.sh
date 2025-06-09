


cleanPreviousArtifacts() {
    rm -rf .tox
    rm -rf build/
    rm -f ripgrep-operator_*.charm
}


# Copy from the mounted directory to the home directory in the Multipass VM
updateMultipass() {
    cp -r /mnt/ripgrep-operator ~/ripgrep-operator
}