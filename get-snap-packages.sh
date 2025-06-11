# This script gets all Snap packages from the shared Multipass VM.

# Due to one system component being private, the Snap package is not available in the Snap Store.
# Consequently, the other components, to maintain consistence, are also not available on the platform.
# As such, each package is accessed via local paths below, and a potential future solution is to use a
# centralized repository or platform to achieve higher maintainability of the codebase.



# Get Snap package from the private CLI repository
getPrivateCLI() {
    rm -rf ~/ripgrep-operator/debian-pkg-analyzer*.snap
    sudo cp -r ~/cli-assignment/debian-pkg-analyzer*.snap ~/ripgrep-operator

    sudo mv ~/ripgrep-operator/debian-pkg-analyzer*.snap ~/ripgrep-operator/debian-pkg-analyzer.snap

    cd ~/ripgrep-operator
    
    # Fix permissions to make it readable
    sudo chown ubuntu:ubuntu debian-pkg-analyzer.snap
    chmod 644 debian-pkg-analyzer.snap
}



# Get Snap package of the Linux distro CLI
getLinuxDistroCLI() {
    echo "TODO"
}




# Formats the package names to conform to the Ripgrep Operator's naming conventions
formatPackage() {
    echo "TODO"
}



# Deploy charm with specific snap version
# juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer_0.2.snap
# juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap