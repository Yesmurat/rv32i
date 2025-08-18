# RV32I 5-stage Pipelined Core

## Overview
This project implements a classic **5-stage pipelined RV32I core** in SystemVerilog with the following:

    - IF, ID, EX, MEM, WB stages
    - Forwarding and hazard detection
    - Instruction and Data memory interface

The design is verified via simulation using Altera Questa FPGA Simulator.

---

## Features
    - Fully functional RV32I base integer instructions (R/I/S/B/J types)
    - 5-stage pipelined with forwarding and stall logic
    - Separate instruction and data memory modules
    - Byte-enable logic for store operations
    - Clear/reset signal handling

---


## Verification
    - 40+ tests cases for each instruction type
    - Waveform snapshots included in `tb/waveforms/`
    - Example assembly programs tested via simulation
    - Testbench supports clock and reset, simulates realistic instruction sequences

---

## FPGA Implementation
    - Target: Intel/Altera FPGA
    - Fmax: 127.45 MHz
    - Resouce: < 1% ALMs
    - Top-level constraints included in `sdc/top.sdc`

---

## Simulation
```
vlog src/*.sv tb/top_tb.sv
vsim top_tb
```
