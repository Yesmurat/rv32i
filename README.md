# RV32I 5-Stage Pipelined Processor

## Overview
This project implements a **5-stage pipelined RV32I RISC-V processor** in SystemVerilog.  
It follows the classic pipeline structure and includes hazard detection, forwarding logic, and memory modules built using FPGA resources.

**Pipeline stages:**
- Instruction Fetch (IF)
- Instruction Decode (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

The design was **simulated and verified in Vivado** and later **tested on the Arty S7-25 FPGA board**.

---

## Features
- Implements all **RV32I base integer instructions** (R, I, S, B, and J types)
- Fully pipelined architecture with **forwarding and stall control**
- Separate **instruction and data memory modules** built from LUTs
- **Byte-enable logic** for store instructions
- Supports **clear/reset** signal and hazard resolution

---

## Verification
- **40+ directed test cases** covering all instruction types
- Testbench includes **clock, reset, and realistic instruction sequences**
- Waveform analysis performed in **Vivado Simulator**
- Example assembly programs located in `tests/`
- Waveform captures available in `tb/waveforms/`

---

## FPGA Implementation
- **Target Board:** Arty S7-25 (Xilinx Spartan-7)
- **Implementation Tool:** Xilinx Vivado
- **Max Frequency (Fmax):** ~100 MHz (post-implementation)
- **Instruction & Data Memories:** Implemented using LUTs (distributed memory)
- **Constraints File:** `xdc/arty_s7_25.xdc`
- **Design tested successfully on real FPGA hardware**

---

## Simulation
To run a functional simulation in Vivado:
```bash
# Read your RTL and testbench files
read_verilog [glob ./src/*.sv]
read_verilog ./tb/top_tb.sv

# Set the top-level testbench module
set_property top top_tb [current_fileset]

# Elaborate and launch simulation
launch_simulation

# (Optional) Add signals to waveform
add_wave *

# Run the simulation
run all