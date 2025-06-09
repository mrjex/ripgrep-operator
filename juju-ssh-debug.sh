

# JUJU_MODEL_REVISION=8

JUJU_MODEL_REVISION=${1}



checkPythonError() {
    juju ssh ripgrep-operator/$JUJU_MODEL_REVISION "sudo cat /var/log/juju/unit-ripgrep-operator-$JUJU_MODEL_REVISION.log | tail -n 50"
}

checkDispatchScript() {
    juju ssh ripgrep-operator/$JUJU_MODEL_REVISION "cat /var/lib/juju/agents/unit-ripgrep-operator-$JUJU_MODEL_REVISION/charm/src/dispatch"
}


checkModuleStructure() {
    juju ssh ripgrep-operator/$JUJU_MODEL_REVISION "ls -la /var/lib/juju/agents/unit-ripgrep-operator-$JUJU_MODEL_REVISION/charm/src/"
}



checkPythonError