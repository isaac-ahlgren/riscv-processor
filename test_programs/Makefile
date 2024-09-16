CC := riscv32-unknown-elf-gcc
OBJDUMP := riscv32-unknown-elf-objdump
OBJCOPY := riscv32-unknown-elf-objcopy

CFLAGS := -O0 -ffunction-sections -Xlinker -g -Trisc.ld -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv -march=rv32i -mabi=ilp32

all:
	$(CC) $(CFLAGS) risc_test.c -o risc_test
	$(CC) $(CFLAGS) merge_sort.c -o merge_sort
	$(CC) $(CFLAGS) blinky.c -o blinky
	$(OBJCOPY) risc_test -O verilog risc_test_verilog.hex
	$(OBJCOPY) merge_sort -O verilog merge_sort_verilog.hex
	$(OBJCOPY) blinky -O verilog blinky.hex

dump:
	$(OBJDUMP) -D blinky

clean:
	rm risc_test risc_test_verilog.hex merge_sort merge_sort_verilog.hex blinky blinky.hex
	

