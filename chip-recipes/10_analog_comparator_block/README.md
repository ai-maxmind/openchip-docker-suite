# 10 — Analog Comparator Block

## Loại chip

Analog/custom block: comparator cơ bản dùng làm ngưỡng cảm biến, ADC SAR, brownout detector hoặc mixed-signal interface.

## File chính

```text
spice/comparator_tb.spice
scripts/run_ngspice.sh
xschem/README_XSCHEM.md
layout/README_LAYOUT.md
```

## Chạy mô phỏng SPICE

```bash
cd chip-recipes/10_analog_comparator_block
bash scripts/run_ngspice.sh
```

## Quy trình thật

1. Vẽ schematic bằng Xschem hoặc Cadence Virtuoso.
2. Mô phỏng bằng ngspice/Xyce hoặc Spectre nếu có.
3. Vẽ layout bằng Magic/KLayout/Virtuoso.
4. Chạy DRC.
5. Chạy LVS bằng Netgen.
6. Extract parasitic.
7. Post-layout simulation.

## Ghi chú

Netlist ở đây là behavioral comparator bằng nguồn phụ thuộc để bạn luyện workflow. Comparator transistor-level thật cần model PDK cụ thể.
