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
async def store_load_test(dut):
     
    register_file = dut.cpu.regs
    sram_data = dut.sr.ram
    cache = dut.cpu.ms.dmem_cache.cch

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


    # Check the expected values for everything
    exp_val = 17

    x8 = int(register_file.qn[7].value)
    x9 = int(register_file.qn[8].value)

    lui_val = 8
    addr = lui_val << 12
    addr_val = int(sram_data[addr >> 2])
    
    cache.re.value = 1
    cache.addr.value = addr
    await Timer(1, units="us")
    cache_addr_val = int(cache.data_out.value)

    assert x8 == exp_val
    assert x9 == addr
    assert addr_val == exp_val
    assert cache_addr_val == exp_val

def test():
    verilog_sources = [f"{SRC_FILE_DIR}{f}" for f in listdir(SRC_FILE_DIR) if isfile(join(SRC_FILE_DIR, f))]
    toplevel = "risc_de10"
    module_name = __file__.strip("/").split("/")[-1].removesuffix(".py")
    test_file = os.getcwd() + "/tests/hex/load_store_instruction_test.hex"

    run(
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module_name,
        includes=[SRC_FILE_DIR],
        waves=True,
        simulator="icarus", 
        parameters={"INIT_PROGRAM" : f"\"{test_file}\""},
        sim_build="build/store_load_build"
    )

if __name__ == "__main__":
    test()