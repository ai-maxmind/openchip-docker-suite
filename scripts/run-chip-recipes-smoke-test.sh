#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-/workspace/chip-recipes}"
for d in \
  01_counter_gpio_chip \
  02_uart_gpio_timer_chip \
  03_pwm_motor_control_chip \
  04_spi_sensor_interface_chip \
  05_i2c_sensor_interface_chip \
  06_tiny_mcu_chip \
  07_vector_mac_accelerator_chip \
  08_crc_crypto_style_chip \
  09_sram_macro_integration_chip \
  12_mixed_signal_sar_adc_controller
 do
  echo "========== $d =========="
  (cd "$ROOT/$d" && make clean && make sim && make synth)
 done
 echo "All digital recipe smoke tests completed."
