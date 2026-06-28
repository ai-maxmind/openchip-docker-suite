# 11 — Simple LDO / Power Management SPICE Block

## Loại chip

Analog power-management block: LDO behavioral model. Dùng để luyện loop, transient, line/load regulation trước khi đi transistor-level.

## Chạy

```bash
cd chip-recipes/11_simple_ldo_spice_block
bash scripts/run_ngspice.sh
```

## Flow thật

- Bandgap/reference.
- Error amplifier.
- Pass transistor.
- Feedback divider.
- Compensation network.
- Current limit/thermal shutdown nếu sản phẩm thật.
- Post-layout extraction và reliability check.
