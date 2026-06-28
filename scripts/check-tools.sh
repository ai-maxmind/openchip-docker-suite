#!/usr/bin/env bash
set +e

echo "=============================="
echo " OpenChip EDA Tool Check"
echo "=============================="
echo

check_cmd() {
  local name="$1"
  local cmd="$2"
  printf "%-28s" "$name"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK  ($(command -v "$cmd"))"
  else
    echo "MISS"
  fi
}

check_py() {
  local name="$1"
  local module="$2"
  printf "%-28s" "$name"
  python3 - <<PY >/dev/null 2>&1
import ${module}
PY
  if [[ $? -eq 0 ]]; then echo "OK"; else echo "MISS"; fi
}

echo "[Digital RTL / verification]"
check_cmd "Verilator" verilator
check_cmd "Icarus Verilog" iverilog
check_cmd "GHDL" ghdl
check_cmd "GTKWave" gtkwave
check_cmd "SymbiYosys/sby" sby
check_cmd "Yosys" yosys
check_cmd "ABC" abc
check_cmd "Surelog" surelog
check_cmd "sv2v" sv2v
check_cmd "Verible formatter" verible-verilog-format
check_py  "cocotb" cocotb
check_py  "pyuvm" pyuvm
check_py  "Amaranth" amaranth

echo
echo "[Synthesis / physical design / signoff]"
check_cmd "OpenROAD" openroad
check_cmd "OpenSTA" sta
check_cmd "KLayout" klayout
check_cmd "Magic" magic
check_cmd "Netgen" netgen
check_cmd "OpenLane 2 CLI" openlane
check_cmd "LibreLane/Sak" librelane
check_cmd "SAK PDK switcher" sak-pdk

echo
echo "[Analog / mixed-signal]"
check_cmd "Xschem" xschem
check_cmd "ngspice" ngspice
check_cmd "Xyce" Xyce
check_cmd "Qucs-S" qucs-s
check_cmd "OpenVAF" openvaf

echo
echo "[Memory / PDK / layout Python]"
check_py  "OpenRAM Python" openram
check_py  "gdstk" gdstk
check_py  "gdspy" gdspy
check_cmd "Ciel PDK manager" ciel

echo
echo "[RISC-V / SoC]"
check_cmd "RISC-V GCC" riscv64-unknown-elf-gcc
check_cmd "Spike" spike
check_cmd "FuseSoC" fusesoc

echo
echo "[Environment]"
echo "PDK_ROOT=${PDK_ROOT:-}"
echo "DESIGN_HOME=${DESIGN_HOME:-}"
echo "WORKSPACE=${WORKSPACE:-}"
echo
echo "Installed PDKs under \$PDK_ROOT:"
if [[ -d "${PDK_ROOT:-/foss/pdks}" ]]; then
  find "${PDK_ROOT:-/foss/pdks}" -maxdepth 1 -mindepth 1 -type d -printf "  - %f\n" | sort
else
  echo "  PDK_ROOT directory not found."
fi

echo
echo "Tip: switch PDK with: sak-pdk sky130A | sak-pdk gf180mcuD | sak-pdk ihp-sg13g2"
