# 02 — UART/GPIO/Timer Chip

## Loại chip

Digital peripheral chip hoặc ngoại vi cho MCU.

## Chạy

```bash
make lint
make sim
make synth
```

## Thành phần

- `timer`: tạo tick định kỳ.
- `uart_tx`: gửi byte UART 8N1.
- `gpio_out`: output debug.

## Mở rộng

- Thêm UART RX.
- Thêm thanh ghi bus APB/Wishbone.
- Thêm interrupt output cho MCU.
