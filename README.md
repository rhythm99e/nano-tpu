# nano-tpu

A 4×4 systolic array accelerator for matrix multiplication, written in 
Verilog/SystemVerilog and targeting the Xilinx Artix-7 FPGA 
(xc7a100tcsg324-1).

Inspired by Google's TPU architecture. Built as a portfolio project for 
graduate research in AI hardware.

## Architecture

- **4×4 grid of Processing Elements (PEs)** performing multiply-accumulate
- **Output-stationary dataflow** — each PE accumulates one output element
- **Data staggering module** for correct temporal alignment
- **8-bit signed inputs**, 32-bit accumulator
- **7-cycle latency** for 4×4 matrix multiply

## Status

- ✅ Design synthesizes cleanly on Xilinx Artix-7
- ✅ 15/16 PEs verified correct with dense matrix test
- 🔨 Investigating edge case in PE(0,0) output
- 📋 DSP48 inference optimization pending
- 📋 Top-level FPGA I/O module pending

## Verification

Testbench performs 4×4 dense matrix multiplication with hand-verified 
expected values and per-cell PASS/FAIL reporting.

## Tools

- Xilinx Vivado 2023.2 (simulation + synthesis)
- Target: xc7a100tcsg324-1 (Artix-7)

## Next Steps

- Complete functional verification
- Add DSP48 inference constraints
- Extend to convolution accelerator
- Integrate with RISC-V control processor

## Author

Rhythm Katwal — ECE, Pulchowk Campus, IOE, Tribhuvan University
