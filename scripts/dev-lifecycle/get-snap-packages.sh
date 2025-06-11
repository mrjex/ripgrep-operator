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



# Get Snap package of the Linux distro CLI (Future extension of the system)
getLinuxDistroCLI() {
    echo "Possible future extension of the system"
}