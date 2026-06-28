# 08 — CRC / Crypto-Style Streaming Chip

## Loại chip

Streaming datapath chip: CRC, checksum, hash preprocessor hoặc crypto-style pipeline cơ bản.

## Chạy

```bash
make lint
make sim
make synth
```

## Mở rộng

- Parallel CRC 8-bit/32-bit.
- Thêm AXI-stream/Wishbone interface.
- Thêm FIFO.
- Thêm scan/test mode khi tapeout thật.
