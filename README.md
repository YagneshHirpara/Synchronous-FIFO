# Synchronous-FIFO

# FIFO Design with Advanced Status Flags in Verilog

This repository contains a **parameterized FIFO (First-In First-Out)** memory module implemented in **Verilog** and simulated on **EDA Playground**. The FIFO is equipped with additional status indicators such as:

- FULL / EMPTY
- ALMOST FULL / ALMOST EMPTY
- HALF FULL / HALF EMPTY

A comprehensive testbench is included to validate the FIFO’s behavior under various conditions including pointer wraparound, flag toggling, and reset behavior.

---

## ✅ Features

- Written in standard **Verilog** (IEEE 1364)
- Parameterized `WIDTH`, `DEPTH`, and `A_FULL_EMPTY`
- Circular buffer-based FIFO implementation
- 6 status outputs:
  - `O_FULL`, `O_EMPTY`
  - `O_AFULL`, `O_AEMPTY`
  - `O_HALF_FULL`, `O_HALF_EMPTY`
- Synchronous Read/Write
- Reset support

---

## 📁 Files

```text
├── FIFO.v         # FIFO Verilog module
├── tb_FIFO.v      # Testbench for simulation and validation
