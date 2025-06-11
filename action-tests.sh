
runArbitraryTests() {
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
}
