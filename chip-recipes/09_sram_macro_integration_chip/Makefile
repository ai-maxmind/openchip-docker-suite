TOP ?= top
RTL_DIR ?= rtl
SIM_DIR ?= sim
BUILD_DIR ?= build
RTL ?= $(wildcard $(RTL_DIR)/*.v)
TB ?= $(SIM_DIR)/$(TOP)_tb.v
YOSYS_SCRIPT ?= scripts/synth.ys

.PHONY: all lint sim synth clean
all: lint sim synth
lint:
	verilator --lint-only -Wall $(RTL)
sim:
	mkdir -p $(BUILD_DIR)
	iverilog -g2012 -DSIM_SRAM -Wall -o $(BUILD_DIR)/$(TOP)_tb.vvp $(RTL) $(TB)
	vvp $(BUILD_DIR)/$(TOP)_tb.vvp
synth:
	mkdir -p $(BUILD_DIR)
	yosys -q -s $(YOSYS_SCRIPT)
clean:
	rm -rf $(BUILD_DIR) *.vcd sim/*.vcd
