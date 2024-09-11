#include <stdint.h>

#define GPIO_REG (volatile uint32_t*) 0x400000

void delay() {
    for (int i = 0; i < 10000; i++)
        asm volatile ("nop");
}

void blink() {
    volatile uint32_t* gpio = GPIO_REG;
    uint32_t state = *gpio;
    state = state ^ 0x3FF;
    *gpio = state;
}

int main() {
    asm volatile ("lui sp, 0x8; addi sp,sp,-16; sw ra,12(sp); sw s0,8(sp)");
    while (1) {
        blink();
        delay();
    }
}