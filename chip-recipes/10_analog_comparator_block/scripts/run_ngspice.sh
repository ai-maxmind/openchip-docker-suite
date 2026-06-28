#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
ngspice -b -o build/comparator.log spice/comparator_tb.spice
cat build/comparator.log | tail -50
