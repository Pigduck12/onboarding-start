# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.types import LogicArray

# --- HELPER FUNCTIONS ---

def ui_in_logicarray(ncs, bit, sclk):
    """Setup the ui_in value: [7:3] unused, [2]=CS_n, [1]=COPI, [0]=SCLK."""
    return LogicArray(f"00000{ncs}{bit}{sclk}")

async def send_spi_transaction(dut, r_w, address, data):
    """
    Synchronized SPI transaction for 16-bit word:
    [15]: R/W, [14:8]: Address, [7:0]: Data
    """
    data_int = int(data) if isinstance(data, LogicArray) else data
    
    # Combine RW (1 bit), 7-bit Address, and 8-bit Data into a 16-bit word
    full_word = (int(r_w) << 15) | ((address & 0x7F) << 8) | (data_int & 0xFF)

    # Start transaction - pull CS_n low
    ncs, sclk, bit = 0, 0, 0
    dut.ui_in.value = ui_in_logicarray(ncs, bit, sclk)
    await ClockCycles(dut.clk, 10)

    # Send 16 bits to match 'if (bitcount == 4'd15)' in spi_peripheral.v
    for i in range(16):
        bit = (full_word >> (15 - i)) & 0x1
        
        # SCLK Low: Set Data (Setup time)
        sclk = 0
        dut.ui_in.value = ui_in_logicarray(ncs, bit, sclk)
        await ClockCycles(dut.clk, 10) 
        
        # SCLK High: Hardware samples COPI
        sclk = 1
        dut.ui_in.value = ui_in_logicarray(ncs, bit, sclk)
        await ClockCycles(dut.clk, 10) 

    # Finalize: Drop SCLK then raise CS_n to trigger internal latch
    sclk = 0
    dut.ui_in.value = ui_in_logicarray(ncs, bit, sclk)
    await ClockCycles(dut.clk, 10)
    
    ncs = 1
    dut.ui_in.value = ui_in_logicarray(ncs, bit, sclk)
    await ClockCycles(dut.clk, 10)

# --- TESTS ---

@cocotb.test()
async def test_spi(dut):
    dut._log.info("Starting SPI Register Test")
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset Hardware
    dut.ena.value = 1
    dut.ui_in.value = ui_in_logicarray(1, 0, 0) # CS_n high
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # Write 0xF0 to Address 0x00 (reg_uo_en)
    await send_spi_transaction(dut, 1, 0x00, 0xF0)
    
    # Debug Internal State via hierarchy
    spi_data = dut.user_project.spi_peripheral_inst.bitsTransferred.value
    ready = dut.user_project.spi_peripheral_inst.bitCompleted.value
    dut._log.info(f"SPI Shifter Result: {hex(int(spi_data))}")
    dut._log.info(f"SPI Ready Signal: {ready}")

    # Verify Output: uo_out[7:1] should now show bits [7:1] of the data (0xF0 >> 1)
    # This confirms the SPI register latched and the project.v mux is working
    actual_val = (int(dut.uo_out.value) >> 1)
    expected_val = (0xF0 >> 1)
    assert actual_val == expected_val, f"Mismatch: {hex(actual_val)} != {hex(expected_val)}"
    dut._log.info("SPI Register Test Passed")

@cocotb.test()
async def test_pwm_duty(dut):
    dut._log.info("Starting PWM Duty Cycle Verification")
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # 1. Enable PWM on uo_out[1] (Address 0x02, bit 1)
    await send_spi_transaction(dut, 1, 0x02, 0x02)
    # 2. Set Duty Cycle to 25% (64/256) (Address 0x04)
    await send_spi_transaction(dut, 1, 0x04, 0x40)
    
    # Measure the high time vs period on uo_out[1]
    await RisingEdge(dut.uo_out[1])
    t1 = cocotb.utils.get_sim_time(units='ns')
    await FallingEdge(dut.uo_out[1])
    t2 = cocotb.utils.get_sim_time(units='ns')
    await RisingEdge(dut.uo_out[1])
    t3 = cocotb.utils.get_sim_time(units='ns')
    
    duty = ((t2 - t1) / (t3 - t1)) * 100
    dut._log.info(f"Measured PWM Duty Cycle: {duty:.2f}%")
    
    # Allow for some margin due to counter quantization
    assert 24 <= duty <= 26, f"Duty cycle {duty}% out of 25% target range"
    dut._log.info("PWM Duty Cycle Test Passed")
