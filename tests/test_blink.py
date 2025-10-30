import os
from os import listdir
from os.path import isfile, join
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_test.simulator import run

SRC_FILE_DIR = "./src/"

@cocotb.test()
async def blink_test(dut):
     
    expected_val_1 = 0x3FF
    answer_1_addr = 0x100
    expected_val_2 = 0x0
    answer_2_addr = 0x200

    # # Create a 10ns period clock
    clock = Clock(dut.clk, 5, units="us")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Wait 800 clock cycles
    for i in range(800):
         await RisingEdge(dut.clk)

    sram_data_1 = int(dut.sr.ram[answer_1_addr >> 2].value)
    sram_data_2 = int(dut.sr.ram[answer_2_addr >> 2].value)

    assert sram_data_1 == expected_val_1
    assert sram_data_2 == expected_val_2

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"
    module_name = __file__.strip("/").split("/")[-1].removesuffix(".py")
    test_file = os.getcwd() + "/tests/hex/blink_test.hex"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module_name,
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : f"\"{test_file}\""},
        sim_build="build/blink"
    )

if __name__ == "__main__":
    test()