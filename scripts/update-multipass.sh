


cleanPreviousArtifacts() {
    rm -rf .tox
    rm -rf build/
    rm -f ripgrep-operator_*.charm
}


# Copy from the mounted directory to the home directory in the Multipass VM
updateMultipass() {
    cp -r /mnt/ripgrep-operator ~/ripgrep-operator
}



# Remote git, tox and venv dependencies to copy the repository without conflicts
removeExternalDependencies() {
    rm -rf ~/ripgrep-operator
    mkdir ~/ripgrep-operator

    cp -r /mnt/ripgrep-operator/* ~/ripgrep-operator/ 2>/dev/null || true
    cp -r /mnt/ripgrep-operator/.* ~/ripgrep-operator/ 2>/dev/null || true

    rm -rf ~/ripgrep-operator/.git
    rm -rf ~/ripgrep-operator/.tox
    rm -rf ~/ripgrep-operator/.venv
    rm -rf ~/ripgrep-operator/venv

    chmod -R 755 ~/ripgrep-operator
}



