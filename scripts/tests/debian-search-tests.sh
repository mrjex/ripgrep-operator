###   DEBIAN SEARCH TESTS   ###
#
#    - Test the search-and-analyze action of the charm operator

MODEL_REVISION=3


# Test "analyze-and-search" action of the charm operator
runAnalyzeSearchActionTests() {
    # Analyze mode: Search for packages with "python" in arm64 architecture
    juju run ripgrep-operator/$MODEL_REVISION analyze-and-search \
    mode=analyze \
    architecture=arm64 \
    search-pattern="kernel" \
    country=us \
    release=bullseye

    # Compare mode: Compare architectures and search for large file count changes
    juju run ripgrep-operator/$MODEL_REVISION analyze-and-search \
    mode=compare \
    comparison-type=arch \
    value1=arm64 \
    value2=amd64 \
    search-pattern="\+[0-9]{5,}" \
    case-sensitive=true

    # Compare releases and search for specific packages
    juju run ripgrep-operator/$MODEL_REVISION analyze-and-search \
    mode=compare \
    comparison-type=release \
    value1=bullseye \
    value2=bookworm \
    comparison-architecture=amd64 \
    search-pattern="(lib|dev)" \
    format=json
}