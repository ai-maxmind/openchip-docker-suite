# 12 — Mixed-Signal SAR ADC Controller

## Loại chip

Mixed-signal chip: digital controller cho SAR ADC. Analog block gồm sample-and-hold, capacitor DAC và comparator; digital block là SAR logic.

## Chạy digital controller

```bash
make lint
make sim
make synth
```

## Tích hợp analog thật

Top-level mixed-signal cần:

- `sample` điều khiển switch sample/hold.
- `dac_code[7:0]` điều khiển capacitor DAC hoặc resistor DAC.
- `comp_gt` là output comparator analog.
- `done/result` xuất kết quả digital.

## Flow thật

1. Thiết kế comparator bằng Xschem/Virtuoso.
2. Thiết kế DAC capacitor array.
3. Mô phỏng analog transient.
4. Kiểm SAR controller bằng RTL simulation.
5. Co-simulation nếu có môi trường mixed-signal.
6. Layout analog custom + digital P&R.
7. Top-level LVS/DRC.
