#include <stdio.h>

#define VERSION "1.0.0"
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define MIN(a, b) ((a) < (b) ? (a) : (b))

#ifdef DEBUG
#define LOG(msg) printf("DEBUG: %s\n", msg)
#else
#define LOG(msg)
#endif

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

int main() {
    printf("=== Testing Preprocessor ===\n\n");
    
    // Test VERSION macro
    printf("Version: %s\n", VERSION);
    
    // Test MAX macro
    int max_val = MAX(5, 10);
    printf("MAX(5, 10) = %d\n", max_val);
    if (max_val != 10) {
        fprintf(stderr, "MAX macro test failed!\n");
        return 1;
    }
    
    // Test MIN macro
    int min_val = MIN(5, 10);
    printf("MIN(5, 10) = %d\n", min_val);
    if (min_val != 5) {
        fprintf(stderr, "MIN macro test failed!\n");
        return 1;
    }
    
    // Test LOG macro (only prints if DEBUG is defined)
    LOG("This is a debug message");
    
    // Test architecture detection
    #if defined(__riscv) && __riscv_xlen == 64
    printf("Compiled for RISC-V 64-bit\n");
    #else
    fprintf(stderr, "Not compiled for RISC-V 64-bit!\n");
    return 1;
    #endif
    
    // Test STRINGIFY
    printf("STRINGIFY test: " TOSTRING(__riscv_xlen) "\n");
    
    printf("\n========================================\n");
    printf("  All preprocessor tests passed!\n");
    printf("========================================\n");
    
    return 0;
}
