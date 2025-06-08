from src.utils.ripgrep import RipgrepWrapper

def test_basic_search():
    # Initialize the wrapper
    rg = RipgrepWrapper()
    
    # Try different search patterns
    print("Testing text search:")
    result = rg.search("class", "src/", "text")
    print(result)
    
    print("\nTesting JSON search:")
    result = rg.search("def", "src/", "json")
    print(result)
    
    print("\nTesting with context:")
    result = rg.search("ripgrep", "src/", "text", context_lines=2)
    print(result)
    
    print("\nGetting stats:")
    stats = rg.get_stats("src/")
    print(stats)

if __name__ == "__main__":
    test_basic_search()