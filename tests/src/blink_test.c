#include <stdint.h>

#define GPIO_REG (volatile uint32_t*) 0x400000
#define ANSWER_1 (volatile uint32_t*) 0x100
#define ANSWER_2 (volatile uint32_t*) 0x200

void delay() {
    for (int i = 0; i < 1; i++)
        asm volatile ("nop");
}

void blink() {
    volatile uint32_t* gpio = GPIO_REG;
    uint32_t state = *gpio;
    state = state ^ 0x3FF;
    *gpio = state;
}

__attribute__((naked))
int main() {
    asm volatile ("lui sp, 0x8;");
    volatile uint32_t* gpio = GPIO_REG;
    volatile uint32_t* answer_1 = ANSWER_1;
    volatile uint32_t* answer_2 = ANSWER_2;
    blink();
    *answer_1 = *gpio;
    delay();
    blink();
    *answer_2 = *gpio;
    while(1);
}