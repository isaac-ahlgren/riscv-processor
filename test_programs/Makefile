CC := riscv32-unknown-elf-gcc
OBJDUMP := riscv32-unknown-elf-objdump
OBJCOPY := riscv32-unknown-elf-objcopy
MEM_WORD_LENGTH := 4

CFLAGS := -O0 -ffunction-sections -Xlinker -g -Trisc.ld -mbig-endian -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv -march=rv32i -mabi=ilp32

all:
	$(CC) $(CFLAGS) risc_test.c -o risc_test
	$(CC) $(CFLAGS) merge_sort.c -o merge_sort
	$(CC) $(CFLAGS) blinky.c -o blinky
	$(OBJCOPY) --remove-section=.comment --reverse-bytes=$(MEM_WORD_LENGTH) --verilog-data-width $(MEM_WORD_LENGTH) risc_test -O verilog risc_test.hex
	$(OBJCOPY) --remove-section=.comment --reverse-bytes=$(MEM_WORD_LENGTH) --verilog-data-width $(MEM_WORD_LENGTH) merge_sort -O verilog merge_sort.hex
	$(OBJCOPY) --remove-section=.comment --reverse-bytes=$(MEM_WORD_LENGTH) --verilog-data-width $(MEM_WORD_LENGTH) blinky -O verilog blinky.hex

dump:
	$(OBJDUMP) -D blinky

clean:
	rm risc_test risc_test.hex merge_sort merge_sort.hex blinky blinky.hex
	

