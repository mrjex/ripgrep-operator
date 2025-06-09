


removeCharm() {
    REVISION=${1}

    juju remove-application ripgrep-operator --force
    juju remove-unit "ripgrep-operator/${REVISION}" --force
    juju remove-machine ${REVISION} --force

    juju status
}





debugStorageError() {
    juju debug-log --replay | grep "storage-attached"
}

