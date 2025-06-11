

# Prerequisite: Deploy with Snap package as Charm resource
# juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap


# Test "analyze-debian" action of the charm operator
runAnalysysTests() {
    # Basic analysis of arm64 packages from US mirror
    juju run ripgrep-operator/3 analyze-debian architecture=arm64 country=us release=bullseye

    # Get top 5 packages for amd64 from UK mirror in JSON format
    juju run ripgrep-operator/3 analyze-debian architecture=amd64 country=uk release=bookworm count=5 format=json
}

# Test "compare-debian" action of the charm operator
runCompareTests() {
    # Compare different architectures
    juju run ripgrep-operator/2 compare-debian type=arch value1=arm64 value2=amd64

    # Compare different mirrors (requires architecture)
    juju run ripgrep-operator/2 compare-debian type=mirror value1=uk value2=us architecture=amd64

    # Compare different releases (requires architecture)
    juju run ripgrep-operator/2 compare-debian type=release value1=buster value2=bookworm architecture=amd64

    juju run ripgrep-operator/2 compare-debian type=release value1=buster value2=bookworm architecture=amd64 format=json count=3
}


# Test "analyze-and-search" action of the charm operator
runAnalyzeSearchActionTests() {
    # Analyze mode: Search for packages with "python" in arm64 architecture
    juju run ripgrep-operator/4 analyze-and-search \
    mode=analyze \
    architecture=arm64 \
    search-pattern="kernel" \
    country=us \
    release=bullseye

    # Compare mode: Compare architectures and search for large file count changes
    juju run ripgrep-operator/4 analyze-and-search \
    mode=compare \
    comparison-type=arch \
    value1=arm64 \
    value2=amd64 \
    search-pattern="\+[0-9]{5,}" \
    case-sensitive=true

    # Compare releases and search for specific packages
    juju run ripgrep-operator/5 analyze-and-search \
    mode=compare \
    comparison-type=release \
    value1=bullseye \
    value2=bookworm \
    comparison-architecture=amd64 \
    search-pattern="(lib|dev)" \
    format=json

    # Compare mirrors and look for significant changes
    juju run ripgrep-operator/4 analyze-and-search \
    mode=compare \
    comparison-type=mirror \
    value1=uk \
    value2=us \
    comparison-architecture=amd64 \
    search-pattern="(increased|decreased)" \
    case-sensitive=false
}



# TODO: Add tests for "search-pattern" action of the charm operator
