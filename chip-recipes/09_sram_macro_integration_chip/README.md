# 09 — SRAM Macro Integration Chip

## Loại chip

Chip dùng SRAM macro: MCU, accelerator, buffer, FIFO lớn.

## Chạy simulation behavioral

Makefile mặc định chưa thêm `SIM_SRAM`, nên chạy thủ công:

```bash
mkdir -p build
iverilog -g2012 -DSIM_SRAM -o build/top_tb.vvp rtl/*.v sim/top_tb.v
vvp build/top_tb.vvp
```

Synthesis:

```bash
make synth
```

## Dùng OpenRAM thật

1. Tạo SRAM bằng OpenRAM.
2. Copy `.lef`, `.lib`, `.gds`, `.v` vào thư mục macro.
3. Sửa `sram_1rw_blackbox.v` cho khớp tên port macro.
4. Khai báo macro trong OpenLane config.
5. Floorplan để chừa vùng macro.

## Lưu ý

SRAM thật không được synthesize từ reg array lớn khi tapeout; nên dùng macro SRAM.
