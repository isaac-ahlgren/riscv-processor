CC := /home/ikey/repos/riscv-gnu-toolchain/build/bin/riscv32-unknown-elf-gcc
OBJDUMP := /home/ikey/repos/riscv-gnu-toolchain/build/bin/riscv32-unknown-elf-objdump
OBJCOPY := /home/ikey/repos/riscv-gnu-toolchain/build/bin/riscv32-unknown-elf-objcopy
GDB := /home/ikey/repos/riscv-gnu-toolchain/build/bin/riscv32-unknown-elf-gdb

CFLAGS := -O0 -Xlinker -g -Trisc.ld -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv

all:
	$(CC) $(CFLAGS) risc_test.c start.s -o risc_test
	$(CC) $(CFLAGS) merge_sort.c -o merge_sort
	$(OBJCOPY) risc_test -O verilog risc_test_verilog
	$(OBJCOPY) merge_sort -O verilog merge_sort_verilog

dump:
	$(OBJDUMP) -d merge_sort

clean:
	rm risc_test risc_verilog_test merge_sort_test merge_sort.img
	

