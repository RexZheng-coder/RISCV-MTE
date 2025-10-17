#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main() {
    // Test malloc/free
    int *arr = malloc(10 * sizeof(int));
    if (!arr) {
        fprintf(stderr, "malloc failed\n");
        return 1;
    }
    
    for (int i = 0; i < 10; i++) {
        arr[i] = i * i;
    }
    
    if (arr[5] != 25) {
        fprintf(stderr, "Array test failed: expected 25, got %d\n", arr[5]);
        free(arr);
        return 1;
    }
    
    printf("malloc/free test passed\n");
    free(arr);
    
    // Test string functions
    char str[100];
    strcpy(str, "Test string");
    if (strlen(str) != 11) {
        fprintf(stderr, "String test failed: expected length 11, got %zu\n", strlen(str));
        return 1;
    }
    
    printf("String functions test passed\n");
    
    // Test math
    double result = sqrt(16.0);
    if (result != 4.0) {
        fprintf(stderr, "Math test failed: expected 4.0, got %f\n", result);
        return 1;
    }
    
    printf("Math functions test passed\n");
    printf("All stdlib tests passed!\n");
    
    return 0;
}
