#include <stdio.h>

// Recursive fibonacci (intentionally inefficient for testing optimization)
int fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// Function with loop
int sum_array(int *arr, int size) {
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }
    return sum;
}

int main() {
    printf("=== Testing Optimization Levels ===\n\n");
    
    // Test fibonacci
    int fib10 = fibonacci(10);
    printf("fibonacci(10) = %d\n", fib10);
    if (fib10 != 55) {
        fprintf(stderr, "Fibonacci test failed!\n");
        return 1;
    }
    
    // Test array sum
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int sum = sum_array(arr, 10);
    printf("sum_array(1..10) = %d\n", sum);
    if (sum != 55) {
        fprintf(stderr, "Array sum test failed!\n");
        return 1;
    }
    
    printf("\nOptimization test passed!\n");
    return 0;
}
