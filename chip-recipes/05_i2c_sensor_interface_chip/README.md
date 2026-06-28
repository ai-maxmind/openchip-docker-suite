# 05 — I2C Sensor Interface Chip

## Loại chip

Digital chip giao tiếp cảm biến I2C ở mức đơn giản.

## Lưu ý

I2C thật cần pad open-drain, pull-up bên ngoài hoặc internal weak pull-up tùy PDK/IO library. RTL dùng `sda_o` và `sda_oe` để khi tích hợp top-level sẽ nối tới IO open-drain.

## Chạy

```bash
make lint
make sim
make synth
```
