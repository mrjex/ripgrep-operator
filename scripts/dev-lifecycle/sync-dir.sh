##  SYNC DIRECTORY - VM Management  ##

# Remote git, tox and venv dependencies to copy the repository without conflicts
removeExternalDependencies() {
    rm -rf ~/ripgrep-operator
    mkdir ~/ripgrep-operator

    echo "Created new dir"

    cp -r /mnt/ripgrep-operator/* ~/ripgrep-operator/ 2>/dev/null || true

    echo "Copied first"

    # cp -r /mnt/ripgrep-operator/.* ~/ripgrep-operator/ 2>/dev/null || true
    # echo "Copied second"

    # rm -rf ~/ripgrep-operator/.git
    # rm -rf ~/ripgrep-operator/.tox
    # rm -rf ~/ripgrep-operator/.venv
    # rm -rf ~/ripgrep-operator/venv'

    chmod -R 755 ~/ripgrep-operator
}


removeExternalDependencies