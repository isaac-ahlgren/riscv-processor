#include <stdint.h>

#define GPIO_REG (volatile uint32_t*) 0x400000
#define WRITE_ADDR (volatile uint32_t*) 0x100

__attribute__((naked))
int main() {
    asm volatile ("lui sp, 0x8;");
    volatile uint32_t* gpio = GPIO_REG;
    volatile uint32_t* write_addr = WRITE_ADDR;
    uint32_t state = *gpio;
    state = state ^ 0x3FF;
    *gpio = state;
    *write_addr = *gpio;
    while (1);
}