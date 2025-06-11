##  TEMPORARY FILE  ##




# 2/2 Tests pass
runAnalysysTests() {
    # Basic analysis of arm64 packages from US mirror
    juju run ripgrep-operator/1 analyze-debian architecture=arm64 country=us release=bullseye

    # Get top 5 packages for amd64 from UK mirror in JSON format
    juju run ripgrep-operator/1 analyze-debian architecture=amd64 country=uk release=bookworm count=5 format=json
}



# 0/3 Tests pass
runCompareTests() {
    # Compare different architectures
    juju run ripgrep-operator/1 compare-debian comparison_type=arch value1=arm64 value2=amd64

    # Compare different mirrors
    juju run ripgrep-operator/1 compare-debian comparison_type=mirror value1=uk value2=us architecture=amd64

    # Compare different releases
    juju run ripgrep-operator/1 compare-debian comparison_type=release value1=bullseye value2=bookworm architecture=amd64
}
