DIR := ./xpacks/.bin
SRC_DIR := ./tests/src
HEX_DIR := ./tests/hex
OBJ_DIR := ./tests/obj

CC := $(DIR)/riscv-none-elf-gcc
PYTHON := python3
OBJDUMP := $(DIR)/riscv-none-elf-objdump
OBJCOPY := $(DIR)/riscv-none-elf-objcopy
MEM_WORD_LENGTH := 4

CFLAGS := -O0 -ffunction-sections -Xlinker -g -T./tests/risc.ld -mbig-endian -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv -march=rv32i -mabi=ilp32

SRCS = $(wildcard $(SRC_DIR)/*.c)

PROGS = $(patsubst ${SRC_DIR}/%.c,%,$(SRCS))
.PHONY: $(PROGS)

all: $(PROGS)

$(PROGS):
	$(CC) $(CFLAGS) -o $(OBJ_DIR)/$@.o $(SRC_DIR)/$@.c
	$(OBJCOPY) --remove-section=.comment --reverse-bytes=$(MEM_WORD_LENGTH) \
		--verilog-data-width $(MEM_WORD_LENGTH) \
		$(OBJ_DIR)/$@.o -O verilog $(HEX_DIR)/$@.hex

test:
	python3 -m pytest ./tests

dump:
	$(OBJDUMP) -D $(OBJ_DIR)/$(FILE)

clean:
	rm obj/* hex/*
	
