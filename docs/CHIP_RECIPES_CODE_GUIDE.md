# BUILD EACH CHIP TYPE GUIDE — CODE HƯỚNG DẪN XÂY TỪNG LOẠI CHIP

Tài liệu này map từng nhóm chip với recipe code trong thư mục `chip-recipes/`.

## 1. Digital ASIC cơ bản

Dùng: `01_counter_gpio_chip`

```bash
cd chip-recipes/01_counter_gpio_chip
make all
```

Mục tiêu: hiểu clock/reset/GPIO, lint/sim/synth.

## 2. Peripheral chip / MCU peripheral

Dùng: `02_uart_gpio_timer_chip`

```bash
cd chip-recipes/02_uart_gpio_timer_chip
make all
```

Mục tiêu: UART TX, timer tick, GPIO.

## 3. Motor/power control logic chip

Dùng: `03_pwm_motor_control_chip`

```bash
cd chip-recipes/03_pwm_motor_control_chip
make all
```

Mục tiêu: PWM, dead-time, half-bridge gate control logic.

## 4. Sensor interface SPI chip

Dùng: `04_spi_sensor_interface_chip`

```bash
cd chip-recipes/04_spi_sensor_interface_chip
make all
```

Mục tiêu: SPI master transaction, CS/SCLK/MOSI/MISO.

## 5. Sensor interface I2C chip

Dùng: `05_i2c_sensor_interface_chip`

```bash
cd chip-recipes/05_i2c_sensor_interface_chip
make all
```

Mục tiêu: I2C write frame, open-drain style IO split.

## 6. MCU chip

Dùng: `06_tiny_mcu_chip`

```bash
cd chip-recipes/06_tiny_mcu_chip
make all
```

Mục tiêu: CPU toy ISA, program counter, instruction memory, GPIO.

Để thành MCU thật: thay CPU toy bằng Ibex/PicoRV32/VexRiscv, thêm SRAM macro, bus, UART/GPIO/Timer.

## 7. AI/DSP accelerator chip

Dùng: `07_vector_mac_accelerator_chip`

```bash
cd chip-recipes/07_vector_mac_accelerator_chip
make all
```

Mục tiêu: vector MAC INT8, datapath multiply-accumulate.

## 8. CRC / streaming datapath / crypto-style chip

Dùng: `08_crc_crypto_style_chip`

```bash
cd chip-recipes/08_crc_crypto_style_chip
make all
```

Mục tiêu: streaming bit-serial datapath, register update, polynomial logic.

## 9. Memory/SRAM-based chip

Dùng: `09_sram_macro_integration_chip`

```bash
cd chip-recipes/09_sram_macro_integration_chip
make sim
make synth
```

Mục tiêu: tích hợp SRAM macro/blackbox, controller đọc/ghi.

## 10. Analog comparator chip/block

Dùng: `10_analog_comparator_block`

```bash
cd chip-recipes/10_analog_comparator_block
bash scripts/run_ngspice.sh
```

Mục tiêu: analog SPICE simulation, sau đó chuyển sang Xschem/Magic/Netgen.

## 11. LDO / PMIC block

Dùng: `11_simple_ldo_spice_block`

```bash
cd chip-recipes/11_simple_ldo_spice_block
bash scripts/run_ngspice.sh
```

Mục tiêu: power management behavioral simulation.

## 12. Mixed-signal ADC controller chip

Dùng: `12_mixed_signal_sar_adc_controller`

```bash
cd chip-recipes/12_mixed_signal_sar_adc_controller
make all
```

Mục tiêu: SAR ADC digital controller, chuẩn bị tích hợp comparator/DAC analog.

## Checklist chung trước khi đưa vào OpenLane

```text
[ ] RTL lint sạch
[ ] Testbench pass
[ ] Yosys synth pass
[ ] Có SDC clock/reset
[ ] Top module tên `top`
[ ] Không dùng initial block cho logic tapeout, trừ ROM/memory simulation có xử lý riêng
[ ] Không dùng tri-state nội bộ trong core digital
[ ] Reset strategy rõ ràng
[ ] IO direction rõ ràng
```

## Checklist trước tapeout thử nghiệm

```text
[ ] Gate-level simulation nếu có
[ ] STA clean
[ ] DRC clean
[ ] LVS clean
[ ] Antenna clean
[ ] GDS mở được bằng KLayout
[ ] Pinout đúng
[ ] Power/ground rõ ràng
[ ] Padframe/ESD có chiến lược
[ ] Có test plan sau khi nhận chip
```
