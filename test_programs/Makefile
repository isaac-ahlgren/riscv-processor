CC := riscv32-unknown-elf-gcc
OBJDUMP := riscv32-unknown-elf-objdump
OBJCOPY := riscv32-unknown-elf-objcopy

CFLAGS := -O0 -Xlinker -g -Trisc.ld -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv -march=rv32i -mabi=ilp32

all:
	$(CC) $(CFLAGS) risc_test.c start.s -o risc_test
	$(CC) $(CFLAGS) merge_sort.c -o merge_sort
	$(OBJCOPY) risc_test -O verilog risc_test_verilog.txt
	$(OBJCOPY) merge_sort -O verilog merge_sort_verilog.txt

dump:
	$(OBJDUMP) -D risc_test

clean:
	rm risc_test risc_test_verilog.txt merge_sort merge_sort_verilog.txt
	

