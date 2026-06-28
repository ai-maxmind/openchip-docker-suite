#!/usr/bin/env bash
# Source this file inside the container:
#   source /usr/local/bin/eda-env sky130A
#   source /usr/local/bin/eda-env gf180mcuD
#   source /usr/local/bin/eda-env ihp-sg13g2

PDK_CHOICE="${1:-sky130A}"

export PDK_ROOT="${PDK_ROOT:-/foss/pdks}"
export PDK="$PDK_CHOICE"
export PDKPATH="$PDK_ROOT/$PDK"

case "$PDK" in
  sky130A|sky130B)
    export STD_CELL_LIBRARY="${STD_CELL_LIBRARY:-sky130_fd_sc_hd}"
    ;;
  gf180mcuA|gf180mcuB|gf180mcuC|gf180mcuD)
    export STD_CELL_LIBRARY="${STD_CELL_LIBRARY:-gf180mcu_fd_sc_mcu7t5v0}"
    ;;
  ihp-sg13g2)
    export STD_CELL_LIBRARY="${STD_CELL_LIBRARY:-sg13g2_stdcell}"
    ;;
  ihp-sg13cmos5l)
    export STD_CELL_LIBRARY="${STD_CELL_LIBRARY:-sg13cmos5l_stdcell}"
    ;;
  *)
    echo "Unknown PDK '$PDK'. Keeping generic env."
    ;;
esac

export SPICE_USERINIT_DIR="$PDKPATH/libs.tech/ngspice"
export KLAYOUT_PATH="$PDKPATH/libs.tech/klayout"

echo "PDK=$PDK"
echo "PDKPATH=$PDKPATH"
echo "STD_CELL_LIBRARY=$STD_CELL_LIBRARY"
echo "SPICE_USERINIT_DIR=$SPICE_USERINIT_DIR"
echo "KLAYOUT_PATH=$KLAYOUT_PATH"
