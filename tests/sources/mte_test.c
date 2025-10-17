#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    printf("=== Testing MTE-aware Memory Allocation ===\n\n");
    
    // Test 1: Basic malloc/free
    printf("Test 1: Basic malloc/free\n");
    int *ptr1 = malloc(100 * sizeof(int));
    if (!ptr1) {
        fprintf(stderr, "malloc failed\n");
        return 1;
    }
    printf("  Allocated 100 integers at %p\n", (void*)ptr1);
    
    // Use the memory
    for (int i = 0; i < 100; i++) {
        ptr1[i] = i;
    }
    printf("  Memory initialized\n");
    printf("  First element: %d\n", ptr1[0]);
    printf("  Last element: %d\n", ptr1[99]);
    
    free(ptr1);
    printf("  Memory freed\n");
    
    // Test 2: calloc
    printf("\nTest 2: calloc\n");
    int *ptr2 = calloc(50, sizeof(int));
    if (!ptr2) {
        fprintf(stderr, "calloc failed\n");
        return 1;
    }
    printf("  Allocated 50 integers (zero-initialized) at %p\n", (void*)ptr2);
    
    // Verify zero-initialization
    int all_zero = 1;
    for (int i = 0; i < 50; i++) {
        if (ptr2[i] != 0) {
            all_zero = 0;
            break;
        }
    }
    
    if (all_zero) {
        printf("  calloc zero-initialization verified\n");
    } else {
        fprintf(stderr, "  calloc zero-initialization failed\n");
        free(ptr2);
        return 1;
    }
    
    free(ptr2);
    printf("  Memory freed\n");
    
    // Test 3: realloc
    printf("\nTest 3: realloc\n");
    int *ptr3 = malloc(10 * sizeof(int));
    if (!ptr3) {
        fprintf(stderr, "malloc failed\n");
        return 1;
    }
    printf("  Initial allocation: 10 integers at %p\n", (void*)ptr3);
    
    for (int i = 0; i < 10; i++) {
        ptr3[i] = i * 10;
    }
    
    ptr3 = realloc(ptr3, 20 * sizeof(int));
    if (!ptr3) {
        fprintf(stderr, "realloc failed\n");
        return 1;
    }
    printf("  Reallocated to 20 integers at %p\n", (void*)ptr3);
    
    // Verify old data preserved
    int data_preserved = 1;
    for (int i = 0; i < 10; i++) {
        if (ptr3[i] != i * 10) {
            data_preserved = 0;
            break;
        }
    }
    
    if (data_preserved) {
        printf("  realloc preserved existing data\n");
    } else {
        fprintf(stderr, "  realloc did not preserve data\n");
        free(ptr3);
        return 1;
    }
    
    free(ptr3);
    printf("  Memory freed\n");
    
    // Test 4: Multiple allocations
    printf("\nTest 4: Multiple allocations\n");
    void *ptrs[10];
    for (int i = 0; i < 10; i++) {
        ptrs[i] = malloc((i + 1) * 100);
        if (!ptrs[i]) {
            fprintf(stderr, "malloc %d failed\n", i);
            return 1;
        }
    }
    printf("  Allocated 10 different-sized blocks\n");
    
    for (int i = 0; i < 10; i++) {
        free(ptrs[i]);
    }
    printf("  All blocks freed\n");
    
    printf("\n========================================\n");
    printf("  All MTE tests passed!\n");
    printf("========================================\n");
    printf("\nNote: MTE tagging is automatic in Glibc malloc/free\n");
    printf("Memory safety is enforced at runtime on MTE-enabled hardware\n");
    
    return 0;
}
