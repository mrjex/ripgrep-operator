##  ENTRYPOINTS TO CALL CLI VIA SYSTEM  ##


# First, attach the Snap resource when deploying
juju deploy ./ripgrep-operator --resource debian-pkg-analyzer=./debian-pkg-analyzer.snap

# Then use the actions
juju run-action ripgrep-operator/0 analyze-debian architecture=arm64 count=8 country=us release=bullseye
juju run-action ripgrep-operator/0 compare-debian comparison_type=mirror value1=uk value2=us architecture=arm64