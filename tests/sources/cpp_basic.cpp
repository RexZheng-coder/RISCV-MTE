#include <iostream>

class TestClass {
public:
    TestClass(int val) : value(val) {
        std::cout << "TestClass constructed with value: " << value << std::endl;
    }
    
    ~TestClass() {
        std::cout << "TestClass destructed" << std::endl;
    }
    
    int getValue() const { 
        return value; 
    }
    
    void setValue(int val) {
        value = val;
    }
    
private:
    int value;
};

int main() {
    std::cout << "Hello from C++!" << std::endl;
    
    // Test class instantiation
    TestClass obj(42);
    
    if (obj.getValue() != 42) {
        std::cerr << "Class test failed: expected 42, got " << obj.getValue() << std::endl;
        return 1;
    }
    
    std::cout << "Class test passed" << std::endl;
    
    // Test method call
    obj.setValue(100);
    if (obj.getValue() != 100) {
        std::cerr << "Method test failed" << std::endl;
        return 1;
    }
    
    std::cout << "Method test passed" << std::endl;
    std::cout << "All C++ basic tests passed!" << std::endl;
    
    return 0;
}
