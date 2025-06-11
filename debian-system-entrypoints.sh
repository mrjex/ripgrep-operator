##  ENTRYPOINTS TO CALL CLI VIA SYSTEM  ##

# First, attach the Snap resource when deploying
juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap

# Basic package analysis examples
echo "Running basic package analysis examples..."
# Analyze arm64 packages from US mirror
juju run ripgrep-operator/0 analyze-debian architecture=arm64 count=8 country=us release=bullseye
# Analyze amd64 packages from UK mirror with JSON output
juju run ripgrep-operator/0 analyze-debian architecture=amd64 country=uk release=bookworm format=json

# Mirror comparison examples
echo "Running mirror comparison examples..."
# Compare UK vs US mirrors for arm64
juju run ripgrep-operator/0 compare-debian comparison_type=mirror value1=uk value2=us architecture=arm64
# Compare DE vs FR mirrors for amd64
juju run ripgrep-operator/0 compare-debian comparison_type=mirror value1=de value2=fr architecture=amd64

# Architecture comparison examples
echo "Running architecture comparison examples..."
# Compare arm64 vs amd64 architectures
juju run ripgrep-operator/0 compare-debian comparison_type=arch value1=arm64 value2=amd64
# Compare i386 vs amd64 architectures
juju run ripgrep-operator/0 compare-debian comparison_type=arch value1=i386 value2=amd64

# Release comparison examples
echo "Running release comparison examples..."
# Compare bullseye vs bookworm releases
juju run ripgrep-operator/0 compare-debian comparison_type=release value1=bullseye value2=bookworm
# Compare buster vs bullseye releases
juju run ripgrep-operator/0 compare-debian comparison_type=release value1=buster value2=bullseye

# Combined analysis with search pattern examples
echo "Running combined analysis with search pattern examples..."
# Analyze packages and search for "security" in the output
juju run ripgrep-operator/0 analyze-debian architecture=amd64 count=20 format=json
juju run ripgrep-operator/0 search-pattern pattern="security" path="./analyze-output"

# Compare mirrors and search for specific package names
juju run ripgrep-operator/0 compare-debian comparison_type=mirror value1=us value2=uk architecture=amd64
juju run ripgrep-operator/0 search-pattern pattern="python" path="./compare-output"

# Advanced examples with different formats and filters
echo "Running advanced examples..."
# Analyze large number of packages and filter for specific patterns
juju run ripgrep-operator/0 analyze-debian architecture=amd64 count=50 country=de release=bookworm format=json
juju run ripgrep-operator/0 search-pattern pattern="version:[[:space:]]*[0-9]+" path="./analyze-output" format=json

# Compare releases and search for dependency information
juju run ripgrep-operator/0 compare-debian comparison_type=release value1=bullseye value2=bookworm architecture=amd64
juju run ripgrep-operator/0 search-pattern pattern="Depends:" path="./compare-output"