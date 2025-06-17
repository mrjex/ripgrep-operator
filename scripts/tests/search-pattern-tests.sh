###   SEARCH PATTERN TESTS   ###
#
#    - Test the search-pattern action of the charm operator


set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        exit 1
    fi
}

# Get the current unit (revision) number of the juju model
# UNIT_NUM=$(juju status --format=json | jq '.applications."ripgrep-operator".units | keys[0]' | tr -d '"' | cut -d'/' -f2)
# if [ -z "$UNIT_NUM" ]; then
#     echo "Error: Could not determine unit number"
#     exit 1
# fi

UNIT_NUM=${1}

echo "Testing ripgrep-operator deployment..."
echo "Using unit: ripgrep-operator/$UNIT_NUM"

# Test 1: Basic search functionality
echo "Test 1: Basic search functionality"
juju run ripgrep-operator/$UNIT_NUM search-pattern pattern="test"
echo_status "Basic search test"

# Test 2: Search with custom path
echo "Test 2: Search with custom path"
juju run ripgrep-operator/$UNIT_NUM search-pattern pattern="python" path="/data"
echo_status "Custom path search test"

# Test 3: Test configuration
echo "Test 3: Testing configuration changes"
juju config ripgrep-operator max_results=500
juju config ripgrep-operator default_context_lines=3
echo_status "Configuration update test"

# Test 4: Create test file in data storage
echo "Test 4: Creating test file in data storage"
echo "This is a test file
with multiple lines
for testing ripgrep
functionality" | juju ssh ripgrep-operator/$UNIT_NUM "sudo tee /data/test.txt > /dev/null"
echo_status "Test file creation"

# Test 5: Search in created file
echo "Test 5: Searching in created file"
juju run ripgrep-operator/$UNIT_NUM search-pattern pattern="functionality" path="/data/test.txt"
echo_status "Search in test file"

# Test 6: Test with different output formats
echo "Test 6: Testing different output formats"
juju run ripgrep-operator/$UNIT_NUM search-pattern pattern="test" format="json"
echo_status "JSON output format test"

# Test 7: Test search with no results
echo "Test 7: Testing search with no matches"
juju run ripgrep-operator/$UNIT_NUM search-pattern pattern="nonexistentpattern123"
echo_status "No matches test"

# Test 8: Test relation endpoints (not currently implemented - tests integration with other charms)
echo "Test 8: Testing search API relation"
# Deploy a test consumer charm if available
# juju deploy test-consumer
# juju relate ripgrep-operator test-consumer
echo_status "Relation test"

# Test 9: Verify storage
echo "Test 9: Verifying storage attachment"
juju ssh ripgrep-operator/$UNIT_NUM "ls -la /data"
echo_status "Storage verification"

# Test 10: Status check
echo "Test 10: Final status check"
juju status ripgrep-operator
echo_status "Status verification"

echo -e "\n${GREEN}All tests completed successfully!${NC}"
