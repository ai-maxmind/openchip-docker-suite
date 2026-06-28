# 01 — Counter/GPIO Chip

## Loại chip

Digital ASIC nhỏ: bộ đếm + GPIO output. Đây là bài đầu tiên để kiểm tra toàn bộ flow.

## Chạy

```bash
make lint
make sim
make synth
```

## Ý tưởng thiết kế

- `clk`: clock chính.
- `rst_n`: reset active-low.
- `gpio_in[3:0]`: input bên ngoài.
- `gpio_out[7:0]`: output từ counter XOR với input.

## Mở rộng

- Thêm thanh ghi cấu hình.
- Thêm bus APB/Wishbone.
- Đưa ra padframe thật khi tapeout.
