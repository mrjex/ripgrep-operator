###   DEBIAN TESTS   ###
#
#    - Test the Snap package of the private CLI tool

# Prerequisite: Deploy with Snap package as Charm resource

MODEL_REVISION=3

# Test "analyze-debian" action of the charm operator
runAnalysysTests() {
    # Basic analysis of arm64 packages from US mirror
    juju run ripgrep-operator/$MODEL_REVISION analyze-debian architecture=arm64 country=us release=bullseye

    # Get top 5 packages for amd64 from UK mirror in JSON format
    juju run ripgrep-operator/$MODEL_REVISION analyze-debian architecture=amd64 country=uk release=bookworm count=5 format=json
}

# Test "compare-debian" action of the charm operator
runCompareTests() {
    # Compare different architectures
    juju run ripgrep-operator/$MODEL_REVISION compare-debian type=arch value1=arm64 value2=amd64

    # Compare different mirrors (requires architecture)
    juju run ripgrep-operator/$MODEL_REVISION compare-debian type=mirror value1=uk value2=us architecture=amd64

    # Compare different releases (requires architecture)
    juju run ripgrep-operator/$MODEL_REVISION compare-debian type=release value1=buster value2=bookworm architecture=amd64

    juju run ripgrep-operator/$MODEL_REVISION compare-debian type=release value1=buster value2=bookworm architecture=amd64 format=json count=3
}
