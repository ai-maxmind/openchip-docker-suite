#!/usr/bin/env bash
set -euo pipefail

cd /workspace/examples/counter

echo "1) Icarus Verilog simulation"
iverilog -g2012 -o sim/counter_tb.vvp rtl/counter.v sim/counter_tb.v
vvp sim/counter_tb.vvp

echo
echo "2) Yosys synthesis smoke test"
yosys -q -p "read_verilog rtl/counter.v; synth -top counter; stat"

echo
echo "Counter example OK."
