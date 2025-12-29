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
async def fib_test(dut):
     
    expected_vals = [2,1]
    beginning_addr = 0x100

    # Create a 10ns period clock
    clock = Clock(dut.clk, 5, units="us")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Wait 2400 clock cycles
    for i in range(7200):
         await RisingEdge(dut.clk)

    received_vals = []
    addr = beginning_addr
    idx = 0
    for exp_val in expected_vals:
        sram_data = int(dut.sr.ram[(addr >> 2) + idx].value)
        received_vals.append(sram_data)
        idx += 1

    print(received_vals)

    for exp_val, rec_val in zip(expected_vals, received_vals):
        assert exp_val == rec_val

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"
    module_name = __file__.strip("/").split("/")[-1].removesuffix(".py")
    test_file = os.getcwd() + "/tests/hex/merge_sort_test_2.hex"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module_name,
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : f"\"{test_file}\""},
        sim_build="build/merge_sort_2"
    )

if __name__ == "__main__":
    test()