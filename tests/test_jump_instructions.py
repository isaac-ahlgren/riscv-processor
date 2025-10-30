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
async def jump_test(dut):
     
    register_file = dut.cpu.regs

    # # Create a 10ns period clock
    clock = Clock(dut.clk, 5, units="us")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Wait 100 clock cycles
    for i in range(100):
         await RisingEdge(dut.clk)

    x31 = int(register_file.qn[30].value)
    x30 = int(register_file.qn[29].value)
    x29 = int(register_file.qn[28].value)
    x28 = int(register_file.qn[27].value)
    x8  = int(register_file.qn[7].value)
    x4  = int(register_file.qn[3].value)
    x5  = int(register_file.qn[4].value)

    assert x31 == 0
    assert x30 == 0
    assert x29 == 0
    assert x28 == 1
    assert x8 == 0x10
    assert x4 == 0xC
    assert x5 == 0x18

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"
    module_name = __file__.strip("/").split("/")[-1].removesuffix(".py")
    test_file = os.getcwd() + "/tests/hex/jump_instructions_test.hex"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module_name,
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : f"\"{test_file}\""},
        sim_build="build/jump_build"
    )

if __name__ == "__main__":
    test()