#include "mylib.h"

int lib_add(int a, int b) {
    return a + b;
}

int lib_subtract(int a, int b) {
    return a - b;
}

int lib_multiply(int a, int b) {
    return a * b;
}

int lib_power(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
        result *= base;
    }
    return result;
}
