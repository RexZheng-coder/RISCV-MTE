#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <memory>
#include <map>

int main() {
    std::cout << "Testing C++ STL..." << std::endl;
    
    // Test 1: Vector
    std::cout << "\n=== Testing std::vector ===" << std::endl;
    std::vector<int> vec = {5, 2, 8, 1, 9};
    std::sort(vec.begin(), vec.end());
    
    if (vec[0] != 1 || vec[4] != 9) {
        std::cerr << "Vector test failed!" << std::endl;
        return 1;
    }
    
    std::cout << "Sorted vector: ";
    for (int v : vec) {
        std::cout << v << " ";
    }
    std::cout << std::endl;
    std::cout << "Vector test passed!" << std::endl;
    
    // Test 2: String
    std::cout << "\n=== Testing std::string ===" << std::endl;
    std::string str = "C++ STL works!";
    if (str.length() != 14) {
        std::cerr << "String test failed: expected length 14, got " << str.length() << std::endl;
        return 1;
    }
    
    std::cout << "String: " << str << std::endl;
    std::cout << "String test passed!" << std::endl;
    
    // Test 3: unique_ptr
    std::cout << "\n=== Testing std::unique_ptr ===" << std::endl;
    auto ptr = std::make_unique<int>(42);
    if (*ptr != 42) {
        std::cerr << "unique_ptr test failed!" << std::endl;
        return 1;
    }
    
    std::cout << "unique_ptr value: " << *ptr << std::endl;
    std::cout << "unique_ptr test passed!" << std::endl;
    
    // Test 4: shared_ptr
    std::cout << "\n=== Testing std::shared_ptr ===" << std::endl;
    auto shared1 = std::make_shared<int>(100);
    auto shared2 = shared1;  // Copy shared pointer
    
    if (*shared1 != 100 || *shared2 != 100) {
        std::cerr << "shared_ptr test failed!" << std::endl;
        return 1;
    }
    
    std::cout << "shared_ptr value: " << *shared1 << std::endl;
    std::cout << "Reference count: " << shared1.use_count() << std::endl;
    std::cout << "shared_ptr test passed!" << std::endl;
    
    // Test 5: Map
    std::cout << "\n=== Testing std::map ===" << std::endl;
    std::map<std::string, int> ages;
    ages["Alice"] = 30;
    ages["Bob"] = 25;
    ages["Charlie"] = 35;
    
    if (ages["Bob"] != 25) {
        std::cerr << "Map test failed!" << std::endl;
        return 1;
    }
    
    std::cout << "Map contents:" << std::endl;
    for (const auto& pair : ages) {
        std::cout << "  " << pair.first << ": " << pair.second << std::endl;
    }
    std::cout << "Map test passed!" << std::endl;
    
    std::cout << "\n========================================" << std::endl;
    std::cout << "  All STL tests passed!" << std::endl;
    std::cout << "========================================" << std::endl;
    
    return 0;
}
