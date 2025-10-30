#include <stdint.h>

#define ANSWER_1 (uint32_t*) 0x100

void fib(uint32_t n1, uint32_t n2, uint32_t N, uint32_t* arr) {
    uint32_t val;
    if (N == 0) {
        return;
    }
    val = n1 + n2;
    *arr = val;
    fib(n2, val, --N, ++arr);
    return;
}

__attribute__ ((naked, section (".text.main")))
int main() {
    asm volatile ("lui sp,0x8");
    uint32_t* nums = ANSWER_1;
    fib(0, 1, 2, nums);
}