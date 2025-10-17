#include <stdio.h>
#include "mylib.h"

int main() {
    printf("=== Testing Static Library ===\n\n");
    
    // Test lib_add
    int sum = lib_add(10, 20);
    printf("lib_add(10, 20) = %d\n", sum);
    if (sum != 30) {
        fprintf(stderr, "lib_add test failed!\n");
        return 1;
    }
    
    // Test lib_subtract
    int diff = lib_subtract(50, 20);
    printf("lib_subtract(50, 20) = %d\n", diff);
    if (diff != 30) {
        fprintf(stderr, "lib_subtract test failed!\n");
        return 1;
    }
    
    // Test lib_multiply
    int product = lib_multiply(5, 6);
    printf("lib_multiply(5, 6) = %d\n", product);
    if (product != 30) {
        fprintf(stderr, "lib_multiply test failed!\n");
        return 1;
    }
    
    // Test lib_power
    int power = lib_power(2, 5);
    printf("lib_power(2, 5) = %d\n", power);
    if (power != 32) {
        fprintf(stderr, "lib_power test failed!\n");
        return 1;
    }
    
    printf("\n========================================\n");
    printf("  All library tests passed!\n");
    printf("========================================\n");
    
    return 0;
}
