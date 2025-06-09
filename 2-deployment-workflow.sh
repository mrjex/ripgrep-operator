# Deploy the Charm Operator

charmcraft pack
# juju deploy ./ripgrep-operator_ubuntu-20.04-amd64.charm
# juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm
# juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm --storage data=10G --storage search-cache=1G
#juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm --storage data=10G
juju deploy ./ripgrep-operator_ubuntu-22.04-amd64-arm64.charm

# Wait until the status is "active"
juju status --watch 1s

# Check status
juju status


# Run an analysis
juju run-action ripgrep-operator/0 analyze package=nginx pattern="version"

# Basic search pattern
juju run-action ripgrep-operator/0 search-pattern pattern="class" path="src/" format="text" --wait

# JSON format search
juju run-action ripgrep-operator/0 search-pattern pattern="def" path="src/" format="json" --wait

# Search pattern with context
juju run-action ripgrep-operator/0 search-pattern pattern="class" path="src/" format="text" context-lines=2 --wait

# Search pattern with context and limit
juju run-action ripgrep-operator/0 search-pattern pattern="class" path="src/" format="text" context-lines=2 limit=10 --wait
