


# Test "analyze" action of the charm operator
runAnalyzeActionTests() {
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


runAnalyzeSearchActionTests() {
    # Analyze mode: Search for packages with "python" in arm64 architecture
    juju run ripgrep-operator/3 analyze-and-search \
    mode=analyze \
    architecture=arm64 \
    search-pattern="python" \
    country=us \
    release=bullseye

    # Compare mode: Compare architectures and search for large file count changes
    juju run ripgrep-operator/3 analyze-and-search \
    mode=compare \
    comparison-type=arch \
    value1=arm64 \
    value2=amd64 \
    search-pattern="\+[0-9]{5,}" \
    case-sensitive=true

    # Compare releases and search for specific packages
    juju run ripgrep-operator/3 analyze-and-search \
    mode=compare \
    comparison-type=release \
    value1=bullseye \
    value2=bookworm \
    comparison-architecture=amd64 \
    search-pattern="(lib|dev)" \
    format=json

    # Compare mirrors and look for significant changes
    juju run ripgrep-operator/3 analyze-and-search \
    mode=compare \
    comparison-type=mirror \
    value1=uk \
    value2=us \
    comparison-architecture=amd64 \
    search-pattern="(increased|decreased)" \
    case-sensitive=false
}
