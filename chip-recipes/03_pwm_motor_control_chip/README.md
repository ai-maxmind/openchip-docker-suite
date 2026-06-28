# 03 — PWM Motor/Power Control Chip

## Loại chip

Digital control chip cho motor driver, LED dimmer, buck controller đơn giản hoặc power-control logic.

## Lưu ý an toàn kỹ thuật

RTL này chỉ là logic điều khiển PWM. Chip công suất thật cần driver analog, level shifter, ESD, bảo vệ quá dòng/quá nhiệt, isolation và signoff công suất.

## Chạy

```bash
make lint
make sim
make synth
```
