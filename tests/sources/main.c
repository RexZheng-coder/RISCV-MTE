#include <stdio.h>
#include "math_utils.h"

int main() {
    printf("=== Testing Multi-file Compilation ===\n\n");
    
    // Test add
    int sum = add(5, 3);
    printf("add(5, 3) = %d\n", sum);
    if (sum != 8) {
        fprintf(stderr, "Add test failed!\n");
        return 1;
    }
    
    // Test subtract
    int diff = subtract(10, 4);
    printf("subtract(10, 4) = %d\n", diff);
    if (diff != 6) {
        fprintf(stderr, "Subtract test failed!\n");
        return 1;
    }
    
    // Test multiply
    int product = multiply(5, 3);
    printf("multiply(5, 3) = %d\n", product);
    if (product != 15) {
        fprintf(stderr, "Multiply test failed!\n");
        return 1;
    }
    
    // Test divide
    double quotient = divide(10.0, 2.0);
    printf("divide(10.0, 2.0) = %.1f\n", quotient);
    if (quotient != 5.0) {
        fprintf(stderr, "Divide test failed!\n");
        return 1;
    }
    
    printf("\n========================================\n");
    printf("  All multi-file tests passed!\n");
    printf("========================================\n");
    
    return 0;
}
