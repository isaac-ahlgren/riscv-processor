import os
from os import listdir
from os.path import isfile, join
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb_test.simulator import run

SRC_FILE_DIR = "./src/"

@cocotb.test()
async def program1_test(dut):
    print(dir(dut))
     
    # # Create a 10ns period clock
    # clock = Clock(dut.clk, 10, units="ns")
    # cocotb.start_soon(clock.start())

    # # # Reset DUT
    # dut.rst.value = 1
    # await RisingEdge(dut.clk)
    # dut.rst.value = 0

    # # Check initial value
    # assert dut.out.value == 0, f"Expected 0 after reset, got {dut.out.value}"

    # # Let it count for 5 cycles
    # for i in range(1, 6):
    #     await RisingEdge(dut.clk)
    #     assert dut.out.value == i, f"Counter mismatch: expected {i}, got {dut.out.value}"

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=__file__.strip("/").split("/")[-1].removesuffix(".py"),
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : "\"./tests/hex/risc_test.hex\""},
    )

if __name__ == "__main__":
    test()