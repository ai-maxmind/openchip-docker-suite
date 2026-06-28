#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
ngspice -b -o build/ldo.log spice/ldo_behavioral_tb.spice
cat build/ldo.log | tail -50
