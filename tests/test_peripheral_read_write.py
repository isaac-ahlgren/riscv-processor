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
async def write_read_periph_test(dut):
     
    expected_val = 0x3FF
    write_addr = 0x100

    # # Create a 10ns period clock
    clock = Clock(dut.clk, 5, units="us")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Wait 200 clock cycles
    for i in range(200):
         await RisingEdge(dut.clk)

    sram_data = int(dut.sr.ram[write_addr >> 2].value)
    peripheral_reg_val = int(dut.periph.qn[0].value)

    assert sram_data == expected_val
    assert peripheral_reg_val == expected_val

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"
    module_name = __file__.strip("/").split("/")[-1].removesuffix(".py")
    test_file = os.getcwd() + "/tests/hex/read_write_to_peripheral_test.hex"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module_name,
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : f"\"{test_file}\""},
        sim_build="build/write_to_peripheral"
    )

if __name__ == "__main__":
    test()