# Check the Python error
juju ssh ripgrep-operator/6 "sudo cat /var/log/juju/unit-ripgrep-operator-6.log | tail -n 50"

# Check the dispatch script
juju ssh ripgrep-operator/6 "cat /var/lib/juju/agents/unit-ripgrep-operator-6/charm/src/dispatch"

# Check if the module structure is correct
juju ssh ripgrep-operator/6 "ls -la /var/lib/juju/agents/unit-ripgrep-operator-6/charm/src/"