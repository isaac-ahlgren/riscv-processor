DIR := ./xpacks/.bin
SRC_DIR := ./tests/src
HEX_DIR := ./tests/hex
BIN_DIR := ./tests/bin
OBJ_DIR := ./tests/obj

CC := $(DIR)/riscv-none-elf-gcc
PYTHON := python3
OBJDUMP := $(DIR)/riscv-none-elf-objdump
OBJCOPY := $(DIR)/riscv-none-elf-objcopy
MEM_WORD_LENGTH := 4

CFLAGS := -O0 -ffunction-sections -Xlinker -g -T./tests/risc.ld -msmall-data-limit=0 -mlittle-endian -nostdlib -ffreestanding -fno-pie -fno-stack-protector -Wall -mno-fdiv -march=rv32i -mabi=ilp32

SRCS = $(wildcard $(SRC_DIR)/*.c)

PROGS = $(patsubst ${SRC_DIR}/%.c,%,$(SRCS))
.PHONY: $(PROGS)

all: $(PROGS)

$(PROGS):
	mkdir -p $(HEX_DIR) $(BIN_DIR) $(OBJ_DIR)
	$(CC) $(CFLAGS) -o $(OBJ_DIR)/$@.o $(SRC_DIR)/$@.c
	$(OBJCOPY) --remove-section=.comment \
		$(OBJ_DIR)/$@.o -O binary $(BIN_DIR)/$@.bin
	$(PYTHON) ./tests/freedom-bin2hex.py --bit-width=32 $(BIN_DIR)/$@.bin $(HEX_DIR)/$@.hex 

test:
	python3 -m pytest ./tests

dump:
	$(OBJDUMP) -D --disassembler-options=no-aliases $(OBJ_DIR)/$(FILE)

clean:
	rm -r tests/obj/* tests/hex/* build
	
