##  SYNC DIRECTORY - VM Management  ##

# Remote git, tox and venv dependencies to copy the repository without conflicts
removeExternalDependencies() {
    rm -rf ~/ripgrep-operator
    mkdir ~/ripgrep-operator

    cp -r /mnt/ripgrep-operator/* ~/ripgrep-operator/ 2>/dev/null || true

    chmod -R 755 ~/ripgrep-operator
}


removeExternalDependencies