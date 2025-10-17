#include <stdio.h>

// Simple function for assembly inspection
int add(int a, int b) {
    return a + b;
}

// Function with loop
int factorial(int n) {
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

int main() {
    printf("=== Testing Assembly Generation ===\n\n");
    
    int sum = add(5, 10);
    printf("add(5, 10) = %d\n", sum);
    
    int fact = factorial(5);
    printf("factorial(5) = %d\n", fact);
    
    if (fact != 120) {
        fprintf(stderr, "Factorial test failed!\n");
        return 1;
    }
    
    printf("\nAssembly test passed!\n");
    return 0;
}
