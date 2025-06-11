

PREVIOUS_REVISION=${1}


syncMountedDirectories() {
    cd /
    bash mnt/ripgrep-operator/vm-management.sh
}


deployJujuCharm() {
    cd ~/ripgrep-operator

    # TODO: In the rebuild script, add an argument to check if it should delete previous revision or not,
    # and connect/pipe that argument in this script (it should be an optional parameter)
    bash rebuild-redeploy-new.sh ${PREVIOUS_REVISION}
}


syncMountedDirectories
deployJujuCharm