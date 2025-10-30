__attribute__((naked))
int main() {
    asm volatile ("lui x9, 0x8;\n"       // Set x9 as 0x800
                  "addi x8,x8,0x10;\n"   // Set x8 as 0x10
                  "sw x8,0(x9);\n"       // Store  x8 at x9 (this should not pull a cache line and just write through to memory)
                  "lw x8,0(x9);\n"       // Load the value at x9 into x8 (this should cause a cache miss)
                  "add x8,x8,1;\n"       // Increment x8 by 1
                  "sw x8,0(x9);\n"       // Store x8 back at x9 to check if both the cached version + the main memory version both update correctly
                );
    while(1);
    /*
    End Result:
    - x9 should be 0x8
    - x8 should be 0x11
    - addr 0x8000 should be 0x11
    - addr 0x8000 in chace should be 0x11
    */
} 