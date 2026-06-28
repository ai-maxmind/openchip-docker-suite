# OpenChip Docker Suite 🚀

Bộ Docker này tạo một workstation thiết kế chip mã nguồn mở dựa trên `hpretl/iic-osic-tools:latest`, sau đó bổ sung script kiểm tra và gói Python phục vụ verification/flow.

## Thành phần chính

- Digital RTL/verification: Verilator, Icarus Verilog, GHDL, cocotb, pyuvm, SymbiYosys, GTKWave
- Synthesis: Yosys, ABC
- Physical design: OpenROAD, OpenLane 2/LibreLane, OpenSTA
- Physical verification/layout: Magic, KLayout, Netgen
- Analog/mixed-signal: Xschem, ngspice, Xyce, Qucs-S
- Memory/layout: OpenRAM, gdstk, gdspy
- PDK: SKY130, GF180MCU, IHP SG13G2/SG13CMOS5L nếu có trong base image

## Cài Docker

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

Windows: dùng Docker Desktop + WSL2.

## Build image

```bash
./scripts/build.sh
```

Hoặc:

```bash
docker compose build eda
```

## Chạy terminal EDA

```bash
./scripts/run.sh
```

Hoặc:

```bash
docker compose run --rm eda
```

## Kiểm tra tool

Trong container:

```bash
check-tools
```

## Chạy demo Verilog nhỏ

Trong container:

```bash
counter-demo
```

## Đổi PDK

Trong container:

```bash
sak-pdk sky130A
sak-pdk gf180mcuD
sak-pdk ihp-sg13g2
```

Hoặc:

```bash
source /usr/local/bin/eda-env sky130A
```

## Chạy GUI trên Linux X11

```bash
./scripts/run-gui-linux-x11.sh
```

Trong container:

```bash
klayout &
xschem &
magic &
gtkwave &
```

## Chạy desktop VNC/noVNC gốc của IIC-OSIC-TOOLS

```bash
./scripts/run-iic-vnc-original.sh
```

Mở trình duyệt theo port container in ra, thường là `http://localhost:8080`.

## Ghi chú thực tế

- Cadence Virtuoso, Spectre, Calibre, Synopsys, Siemens Tessent/Questa là phần mềm thương mại, không thể cài hợp pháp bằng Dockerfile mã nguồn mở nếu không có license.
- Bộ này phù hợp nhất cho SKY130/GF180/IHP, digital ASIC, analog/mixed-signal cơ bản đến nâng cao, RISC-V SoC nhỏ/trung bình.
- Không thay thế 100% commercial signoff cho 7/5/3nm, GPU/AI accelerator lớn, HBM/DRAM/NAND, RF/mmWave thương mại.

## Tài liệu sử dụng chi tiết

Xem tài liệu đầy đủ tại:

```text
docs/USER_GUIDE.md
```

## Tài liệu thiết kế chip

```text
docs/CHIP_DESIGN_GUIDE.md
docs/TOOL_MASTERY_GUIDE.md
docs/USER_GUIDE.md
```
