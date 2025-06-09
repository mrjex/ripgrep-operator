# Deploy the Charm Operator

charmcraft pack
juju deploy ./ripgrep-operator_ubuntu-20.04-amd64.charm

# Check status
juju status

# Run an analysis
juju run-action ripgrep-operator/0 analyze package=nginx pattern="version