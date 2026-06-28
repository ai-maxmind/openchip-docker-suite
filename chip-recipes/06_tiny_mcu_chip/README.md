# 06 — Tiny MCU Chip

## Loại chip

MCU giáo dục nhỏ: CPU 16-bit toy ISA + ROM/RAM + GPIO.

## Vì sao không dùng RISC-V hoàn chỉnh trong template này?

RISC-V core đầy đủ nên dùng IP đã được kiểm chứng như Ibex, PicoRV32, VexRiscv. Template này dùng CPU nhỏ tự chứa để bạn hiểu cấu trúc MCU trước: PC, instruction, accumulator, memory bus, GPIO.

## Chạy

```bash
make lint
make sim
make synth
```

## Mở rộng thành MCU thực tế

- Thay `tiny_cpu` bằng Ibex/PicoRV32.
- Thêm ROM/SRAM macro.
- Thêm UART/GPIO/Timer từ các recipe trước.
- Thêm bus Wishbone/APB.
- Thêm bootloader/test firmware.
