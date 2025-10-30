__attribute__((naked))
int main() {
    asm volatile ("j 0x8;\n"            // Jump to 0x8
                  "li x31, -1;\n"       // If it fails, put -1 in x31
                  "jal x4, 0x10;\n"      // Jump to 0x10, place 0xC in x4
                  "li x30, -1;\n"       // If it fails, put -1 in x30
                  "addi x8,x8,0x10;\n"  // Place 0x10 in x8
                  "jalr x5, x8, 0xC;\n" // Jump to 0x1C, place 0x18 in x5
                  "li x29, -1;\n"       // If it fails, put -1 in x29
                  "li x28, 1;"          // Done!
                );
    while(1);
    /*
    End Result:
    x31 is 0
    x30 is 0
    x29 is 0
    x28 is 1s
    x8 is 0x10
    x4 is 0xC
    x5 is 0x18
    */
} 