# OpenChip Chip Recipes

Các thư mục trong `chip-recipes/` là bộ **code mẫu + hướng dẫn xây từng nhóm chip** bằng OpenChip Docker Stack.

## Cách dùng chung

Vào container:

```bash
cd openchip-docker-suite
./scripts/run.sh
```

Trong container:

```bash
cd /workspace/chip-recipes/<recipe-name>
make lint
make sim
make synth
```

Nếu muốn chạy OpenLane/OpenROAD, trước hết chọn PDK:

```bash
source /usr/local/bin/eda-env sky130A
# hoặc
source /usr/local/bin/eda-env gf180mcuD
# hoặc
source /usr/local/bin/eda-env ihp-sg13g2
```

Sau đó tùy phiên bản OpenLane trong image:

```bash
openlane openlane/config.json
# hoặc
openlane --flow Classic openlane/config.json
```

## Thứ tự học khuyến nghị

1. `01_counter_gpio_chip`
2. `02_uart_gpio_timer_chip`
3. `03_pwm_motor_control_chip`
4. `04_spi_sensor_interface_chip`
5. `05_i2c_sensor_interface_chip`
6. `06_tiny_mcu_chip`
7. `07_vector_mac_accelerator_chip`
8. `08_crc_crypto_style_chip`
9. `09_sram_macro_integration_chip`
10. `10_analog_comparator_block`
11. `11_simple_ldo_spice_block`
12. `12_mixed_signal_sar_adc_controller`

## Ghi chú

Các mẫu digital là code RTL giáo dục, đủ để lint/sim/synth cơ bản. Để tapeout thật cần thêm: padframe, power grid, DRC/LVS clean, STA clean, IO cells, ESD, test strategy và review PDK/foundry.
