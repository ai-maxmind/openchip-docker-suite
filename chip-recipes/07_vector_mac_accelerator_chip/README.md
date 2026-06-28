# 07 — Vector MAC Accelerator Chip

## Loại chip

AI/DSP accelerator nhỏ: nhân vector 4 phần tử rồi cộng tích lũy.

## Chạy

```bash
make lint
make sim
make synth
```

## Mở rộng thành AI accelerator lớn hơn

- Pipeline multiplier.
- Thêm SRAM input/output.
- Thêm DMA/bus interface.
- Dùng systolic array.
- Thêm quantization INT8/INT4.
