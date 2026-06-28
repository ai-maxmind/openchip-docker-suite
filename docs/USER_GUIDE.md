# HƯỚNG DẪN SỬ DỤNG OPENCHIP DOCKER SUITE

Phiên bản tài liệu: 1.0  
Mục tiêu: dựng một môi trường thiết kế chip mã nguồn mở trong Docker, phục vụ học tập, nghiên cứu và thiết kế thử nghiệm các mạch số, analog và mixed-signal trên các PDK mở như SKY130, GF180MCU và IHP SG13G2.

---

## 1. OpenChip Docker Suite là gì?

OpenChip Docker Suite là bộ Docker project dùng để biến máy tính cá nhân hoặc server thành một workstation thiết kế chip mã nguồn mở.

Bộ stack này dựa trên image nền:

```bash
hpretl/iic-osic-tools:latest
```

Sau đó bổ sung thêm script, Python package và cấu trúc thư mục để làm việc thuận tiện hơn.

### 1.1. Nhóm công cụ chính

| Nhóm | Công cụ |
|---|---|
| RTL simulation | Verilator, Icarus Verilog, GHDL |
| Verification | cocotb, pyuvm, pytest, SymbiYosys |
| Synthesis | Yosys, ABC |
| Physical design | OpenROAD, OpenLane 2/LibreLane |
| Timing | OpenSTA |
| Layout/DRC/LVS | Magic, KLayout, Netgen |
| Analog/mixed-signal | Xschem, ngspice, Xyce, Qucs-S |
| Memory/Layout scripting | OpenRAM, gdstk, gdspy |
| SoC/IP flow | FuseSoC, Edalize, Amaranth |
| PDK | SKY130, GF180MCU, IHP SG13G2 nếu có trong image |

---

## 2. Bộ này dùng để làm gì?

Phù hợp cho:

- Học thiết kế chip từ RTL đến GDSII.
- Mô phỏng Verilog/SystemVerilog/VHDL.
- Viết testbench bằng Python với cocotb.
- Tổng hợp logic bằng Yosys.
- Place & route bằng OpenROAD/OpenLane.
- Chạy DRC/LVS bằng Magic, KLayout, Netgen.
- Thiết kế analog bằng Xschem/ngspice hoặc Magic/KLayout.
- Thiết kế RISC-V MCU nhỏ, IP số, peripheral, controller, accelerator nhỏ.
- Làm prototype trên PDK mở như SKY130/GF180/IHP.

Không phù hợp để thay thế hoàn toàn:

- Cadence/Synopsys/Siemens signoff thương mại.
- Advanced node 7 nm, 5 nm, 3 nm.
- GPU/AI accelerator thương mại lớn.
- DRAM/NAND/HBM.
- RF/mmWave thương mại phức tạp.
- DFT/ATPG production-grade.

---

## 3. Yêu cầu máy tính

### 3.1. Cấu hình tối thiểu

| Thành phần | Tối thiểu |
|---|---:|
| CPU | 4 core |
| RAM | 8 GB |
| Dung lượng trống | 30–50 GB |
| OS | Ubuntu/Debian/WSL2/macOS/Linux server |

### 3.2. Cấu hình khuyến nghị

| Thành phần | Khuyến nghị |
|---|---:|
| CPU | 8–16 core |
| RAM | 32 GB trở lên |
| Dung lượng trống | 100 GB trở lên |
| OS tốt nhất | Ubuntu Linux native |

Với thiết kế lớn, nên tăng Docker shared memory trong `docker-compose.yml`:

```yaml
shm_size: "8gb"
```

Có thể tăng lên:

```yaml
shm_size: "16gb"
```

---

## 4. Cấu trúc thư mục

Sau khi giải nén, cấu trúc chuẩn là:

```text
openchip-docker-suite/
├── Dockerfile
├── docker-compose.yml
├── README.md
├── docs/
│   └── USER_GUIDE.md
├── scripts/
│   ├── build.sh
│   ├── run.sh
│   ├── run-gui-linux-x11.sh
│   ├── run-iic-vnc-original.sh
│   ├── check-tools.sh
│   ├── eda-env.sh
│   └── run-counter-example.sh
├── examples/
│   └── counter/
│       ├── rtl/counter.v
│       └── sim/counter_tb.v
├── designs/
└── workspace/
```

Ý nghĩa:

| Thư mục/File | Chức năng |
|---|---|
| `Dockerfile` | Công thức build image EDA |
| `docker-compose.yml` | Cấu hình chạy container |
| `scripts/` | Các script build, run, kiểm tra tool |
| `examples/` | Ví dụ mẫu để test môi trường |
| `designs/` | Nơi đặt project thiết kế chip của bạn |
| `workspace/` | Nơi làm việc tạm trong container |
| `docs/` | Tài liệu hướng dẫn |

Trong container:

| Đường dẫn trong container | Map từ máy thật |
|---|---|
| `/foss/designs` | `./designs` |
| `/workspace` | `./workspace` |
| `/workspace/examples` | `./examples` |
| `/foss/pdks` | PDK có sẵn trong image nền |

---

## 5. Cài Docker

### 5.1. Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

Kiểm tra:

```bash
docker --version
docker compose version
```

### 5.2. Windows

Dùng:

- Docker Desktop.
- WSL2 backend.
- Ubuntu trong WSL2.

Khuyến nghị thao tác trong terminal Ubuntu WSL2, không thao tác trực tiếp trong PowerShell nếu project đặt trong ổ Windows vì tốc độ I/O có thể chậm.

### 5.3. macOS

Dùng Docker Desktop for Mac. GUI X11 phức tạp hơn Linux; nếu cần GUI, nên dùng VNC/noVNC hoặc chạy trên máy Linux.

---

## 6. Build image

Vào thư mục project:

```bash
cd openchip-docker-suite
chmod +x scripts/*.sh
```

Build:

```bash
./scripts/build.sh
```

Hoặc dùng trực tiếp Docker Compose:

```bash
docker compose build eda
```

Image sau khi build có tên:

```bash
openchip-eda:latest
```

Kiểm tra image:

```bash
docker images | grep openchip
```

---

## 7. Chạy container terminal

Cách nhanh:

```bash
./scripts/run.sh
```

Hoặc:

```bash
docker compose run --rm eda
```

Sau khi vào container, bạn sẽ thấy môi trường EDA sẵn sàng.

Kiểm tra biến môi trường:

```bash
echo $PDK_ROOT
echo $DESIGN_HOME
echo $WORKSPACE
```

Kết quả thường là:

```bash
/foss/pdks
/foss/designs
/workspace
```

---

## 8. Kiểm tra toàn bộ tool

Trong container, chạy:

```bash
check-tools
```

Hoặc alias ngắn:

```bash
ct
```

Script sẽ kiểm tra các nhóm tool:

- Digital RTL/verification.
- Synthesis/physical design/signoff.
- Analog/mixed-signal.
- Memory/layout Python.
- RISC-V/SoC.
- PDK có trong `$PDK_ROOT`.

Nếu thấy `MISS`, có 3 khả năng chính:

1. Tool không có trong image nền.
2. Tool có nhưng chưa nằm trong `$PATH`.
3. Image nền đã thay đổi phiên bản.

Ví dụ xử lý nhanh:

```bash
which yosys
which openroad
which magic
which xschem
```

Nếu thiếu nhiều tool quan trọng, nên pull lại image nền hoặc rebuild:

```bash
docker compose build --no-cache eda
```

---

## 9. Chạy ví dụ đầu tiên: counter Verilog

Trong container:

```bash
counter-demo
```

Lệnh này chạy hai bước:

```text
1. Icarus Verilog simulation
2. Yosys synthesis smoke test
```

Nếu thành công, môi trường cơ bản đã hoạt động.

Bạn cũng có thể chạy thủ công:

```bash
cd /workspace/examples/counter
iverilog -g2012 -o sim/counter_tb.vvp rtl/counter.v sim/counter_tb.v
vvp sim/counter_tb.vvp
yosys -q -p "read_verilog rtl/counter.v; synth -top counter; stat"
```

---

## 10. Chọn và đổi PDK

PDK là Process Design Kit, tức bộ dữ liệu công nghệ bán dẫn. Không có PDK thì không thể đi từ mạch sang layout manufacturable.

Các PDK thường dùng:

| PDK | Node | Phù hợp |
|---|---:|---|
| `sky130A` | 130 nm | Digital/analog học tập, MPW, RISC-V nhỏ |
| `gf180mcuD` | 180 nm | MCU, analog, mixed-signal |
| `ihp-sg13g2` | 130 nm BiCMOS | Analog/RF/mixed-signal, nghiên cứu |

Đổi PDK bằng tool của image nền:

```bash
sak-pdk sky130A
sak-pdk gf180mcuD
sak-pdk ihp-sg13g2
```

Hoặc source script môi trường:

```bash
source /usr/local/bin/eda-env sky130A
source /usr/local/bin/eda-env gf180mcuD
source /usr/local/bin/eda-env ihp-sg13g2
```

Kiểm tra:

```bash
echo $PDK
echo $PDKPATH
echo $STD_CELL_LIBRARY
```

---

## 11. Workflow digital ASIC cơ bản

Quy trình chuẩn:

```text
RTL
→ lint
→ simulation
→ formal verification
→ synthesis
→ floorplan
→ placement
→ clock tree synthesis
→ routing
→ STA
→ DRC
→ LVS
→ GDSII
```

Tool tương ứng:

| Bước | Tool |
|---|---|
| Lint | Verilator, Verible |
| Simulation | Icarus, Verilator, GHDL |
| Python testbench | cocotb, pyuvm |
| Formal | SymbiYosys |
| Synthesis | Yosys + ABC |
| Place & route | OpenROAD/OpenLane |
| Timing | OpenSTA |
| DRC | Magic/KLayout |
| LVS | Netgen |
| GDS viewer | KLayout |

### 11.1. Lint RTL bằng Verilator

```bash
verilator --lint-only -Wall rtl/top.v
```

### 11.2. Simulation bằng Icarus

```bash
iverilog -g2012 -o sim/top_tb.vvp rtl/top.v sim/top_tb.v
vvp sim/top_tb.vvp
```

### 11.3. Tổng hợp bằng Yosys

```bash
yosys -p "read_verilog rtl/top.v; synth -top top; stat"
```

### 11.4. Xem waveform

Nếu testbench sinh file `dump.vcd`:

```bash
gtkwave dump.vcd
```

---

## 12. Gợi ý cấu trúc một project digital

Trong `designs/`, tạo project:

```bash
mkdir -p designs/my_riscv_chip/{rtl,sim,formal,constraints,openlane,scripts,reports,docs}
```

Cấu trúc:

```text
designs/my_riscv_chip/
├── rtl/
│   └── top.v
├── sim/
│   └── top_tb.v
├── formal/
│   └── top.sby
├── constraints/
│   └── top.sdc
├── openlane/
│   └── config.json
├── scripts/
│   ├── lint.sh
│   ├── sim.sh
│   ├── synth.sh
│   └── pnr.sh
├── reports/
└── docs/
```

### 12.1. Script lint mẫu

`designs/my_riscv_chip/scripts/lint.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
verilator --lint-only -Wall ../rtl/top.v
```

### 12.2. Script simulation mẫu

`designs/my_riscv_chip/scripts/sim.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
iverilog -g2012 -o ../sim/top_tb.vvp ../rtl/top.v ../sim/top_tb.v
vvp ../sim/top_tb.vvp
```

### 12.3. Script synthesis mẫu

`designs/my_riscv_chip/scripts/synth.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
yosys -p "read_verilog ../rtl/top.v; synth -top top; stat"
```

---

## 13. Workflow OpenLane/OpenROAD

Có hai hướng:

1. Dùng OpenLane/LibreLane flow tự động.
2. Dùng OpenROAD thủ công bằng Tcl.

Với người mới, nên bắt đầu bằng OpenLane/LibreLane.

### 13.1. Kiểm tra lệnh có sẵn

Trong container:

```bash
openlane --help
librelane --help
openroad -version
```

Tùy phiên bản image, lệnh chạy flow có thể khác nhau. Nếu `openlane` không có, kiểm tra `librelane` hoặc tài liệu của image nền.

### 13.2. Các file thường cần

Một design chạy OpenLane thường cần:

```text
rtl/top.v
openlane/config.json hoặc config.tcl
constraints/top.sdc
```

Ví dụ `config.json` tối giản:

```json
{
  "DESIGN_NAME": "top",
  "VERILOG_FILES": "dir::../rtl/top.v",
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 10,
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY": 0.55
}
```

Các thông số cần điều chỉnh:

| Tham số | Ý nghĩa |
|---|---|
| `DESIGN_NAME` | Tên top module |
| `VERILOG_FILES` | Danh sách RTL input |
| `CLOCK_PORT` | Tên chân clock |
| `CLOCK_PERIOD` | Chu kỳ clock, đơn vị ns |
| `FP_CORE_UTIL` | Mức sử dụng core |
| `PL_TARGET_DENSITY` | Mật độ placement |

### 13.3. Kết quả cần kiểm tra

Sau khi chạy flow, kiểm tra:

| Kết quả | Ý nghĩa |
|---|---|
| `*.gds` | Layout cuối |
| `*.def` | Placement/routing database |
| `*.lef` | Abstract view |
| `*.sdf` | Delay annotation |
| `*.spef` | Parasitic extraction |
| `reports/` | Timing, area, DRC, LVS |

Không được xem là thành công nếu chỉ có GDS nhưng còn DRC/LVS/timing lỗi.

---

## 14. Workflow analog/mixed-signal

Quy trình analog cơ bản:

```text
Schematic
→ SPICE simulation
→ layout
→ extraction
→ LVS
→ post-layout simulation
→ GDSII
```

Tool tương ứng:

| Bước | Tool |
|---|---|
| Schematic | Xschem |
| Simulation | ngspice/Xyce |
| Layout | Magic/KLayout |
| DRC | Magic/KLayout |
| LVS | Netgen |
| Post-layout simulation | ngspice/Xyce |

### 14.1. Chọn PDK trước

Ví dụ SKY130:

```bash
source /usr/local/bin/eda-env sky130A
```

### 14.2. Mở Xschem

Trên Linux X11 hoặc VNC:

```bash
xschem &
```

### 14.3. Mở Magic

```bash
magic &
```

### 14.4. Mở KLayout

```bash
klayout &
```

### 14.5. Nguyên tắc analog quan trọng

- Luôn mô phỏng schematic trước khi layout.
- Sau layout phải chạy extraction.
- Sau extraction phải chạy LVS.
- Sau LVS phải chạy post-layout simulation.
- Không dùng kết quả schematic-only để kết luận chip sẽ chạy đúng.

---

## 15. Chạy GUI

### 15.1. Linux native với X11

Từ máy host:

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

Nếu lỗi quyền X11:

```bash
xhost +local:docker
```

Sau khi dùng xong, nên khóa lại:

```bash
xhost -local:docker
```

### 15.2. VNC/noVNC

Chạy image VNC gốc:

```bash
./scripts/run-iic-vnc-original.sh
```

Mở trình duyệt:

```text
http://localhost:8080
```

Nếu port 8080 bận, sửa trong script:

```bash
-p 8081:80
```

Rồi mở:

```text
http://localhost:8081
```

---

## 16. Lộ trình học đề xuất

### Giai đoạn 1: Làm quen RTL

Mục tiêu:

- Biết viết Verilog module.
- Biết viết testbench.
- Biết chạy Icarus/Verilator.
- Biết xem waveform bằng GTKWave.

Bài tập:

1. Counter.
2. UART transmitter.
3. SPI master.
4. PWM generator.
5. Simple ALU.

### Giai đoạn 2: Verification

Mục tiêu:

- Viết cocotb test.
- Chạy pytest.
- Làm random test.
- Dùng SymbiYosys chứng minh thuộc tính đơn giản.

Bài tập:

1. FIFO sync.
2. FIFO async.
3. Arbiter.
4. Register file.
5. APB peripheral.

### Giai đoạn 3: Synthesis

Mục tiêu:

- Hiểu cell mapping.
- Đọc report area/timing.
- Chạy Yosys synthesis.

Bài tập:

1. Tổng hợp ALU.
2. Tổng hợp UART.
3. Tổng hợp APB peripheral.
4. So sánh area giữa các kiến trúc.

### Giai đoạn 4: RTL to GDS

Mục tiêu:

- Chạy OpenLane/OpenROAD.
- Đọc report DRC/LVS/STA.
- Mở GDS bằng KLayout.

Bài tập:

1. Counter GDS.
2. UART GDS.
3. SPI GDS.
4. Mini SoC GDS.

### Giai đoạn 5: Mixed-signal

Mục tiêu:

- Vẽ schematic analog.
- Mô phỏng ngspice.
- Layout bằng Magic/KLayout.
- LVS và post-layout simulation.

Bài tập:

1. Inverter transistor-level.
2. Ring oscillator.
3. Current mirror.
4. Comparator.
5. Simple ADC interface.

---

## 17. Quy trình kiểm tra trước khi tapeout thử nghiệm

Một thiết kế chưa nên tapeout nếu chưa đạt các mục sau:

```text
[ ] RTL simulation pass
[ ] cocotb/unit test pass
[ ] Formal property pass nếu có
[ ] Synthesis không lỗi
[ ] Gate-level simulation pass nếu có
[ ] STA không vi phạm nghiêm trọng
[ ] DRC clean
[ ] LVS clean
[ ] Antenna clean hoặc đã xử lý
[ ] GDS mở được bằng KLayout
[ ] Pinout đúng
[ ] Power ring/grid hợp lệ
[ ] Clock/reset rõ ràng
[ ] Tài liệu test chip có sẵn
```

Với mixed-signal thêm:

```text
[ ] Schematic simulation pass
[ ] Layout extraction xong
[ ] Post-layout simulation pass
[ ] Corner simulation nếu có model
[ ] Kiểm tra mismatch/noise nếu cần
```

---

## 18. Lỗi thường gặp và cách xử lý

### 18.1. Docker không chạy do thiếu quyền

Lỗi:

```text
permission denied while trying to connect to Docker daemon
```

Sửa:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 18.2. Build quá lâu hoặc lỗi mạng

Thử:

```bash
docker compose build --no-cache eda
```

Hoặc pull image nền trước:

```bash
docker pull hpretl/iic-osic-tools:latest
```

### 18.3. Không mở được GUI

Kiểm tra:

```bash
echo $DISPLAY
```

Nếu rỗng, bạn đang không ở môi trường GUI X11.

Trên Linux:

```bash
xhost +local:docker
./scripts/run-gui-linux-x11.sh
```

Hoặc dùng VNC:

```bash
./scripts/run-iic-vnc-original.sh
```

### 18.4. Không tìm thấy PDK

Kiểm tra:

```bash
echo $PDK_ROOT
ls $PDK_ROOT
```

Đổi PDK:

```bash
sak-pdk sky130A
```

Hoặc:

```bash
source /usr/local/bin/eda-env sky130A
```

### 18.5. `check-tools` báo MISS

Kiểm tra tool cụ thể:

```bash
which yosys
which openroad
which klayout
```

Nếu thiếu thật, nguyên nhân thường là image nền thay đổi hoặc tool không được cài trong biến thể image hiện tại.

### 18.6. Container hết RAM

Dấu hiệu:

- Process bị kill.
- OpenROAD dừng giữa chừng.
- Docker báo out of memory.

Cách xử lý:

- Tăng RAM Docker Desktop.
- Tăng `shm_size`.
- Giảm kích thước design.
- Giảm density.
- Chạy trên máy Linux/server nhiều RAM hơn.

---

## 19. Quy tắc làm việc nên áp dụng

### 19.1. Mỗi project phải có Git

```bash
cd designs/my_chip
git init
```

Không commit các file quá lớn như build cache, run directory nặng, waveform quá lớn.

### 19.2. Luôn lưu report

Sau mỗi lần chạy flow, lưu:

```text
reports/timing
reports/area
reports/power
reports/drc
reports/lvs
reports/qor
```

### 19.3. Đặt version cho PDK/tool

Không nên chỉ ghi “dùng SKY130”. Cần ghi:

```text
PDK: sky130A
Tool image: openchip-eda:latest
Base image: hpretl/iic-osic-tools:latest
Date: YYYY-MM-DD
```

Tốt hơn nữa là pin image theo digest hoặc tag cố định nếu project nghiêm túc.

### 19.4. Không sửa tay file sinh ra nếu không hiểu

Các file như DEF/GDS/SPEF/SDF nên được sinh lại bằng flow, không nên sửa tay tùy tiện.

---

## 20. Workflow khuyến nghị cho một chip RISC-V nhỏ

Kiến trúc đề xuất:

```text
RISC-V core
+ ROM boot
+ SRAM
+ UART
+ SPI
+ GPIO
+ Timer
+ PWM
+ Wishbone/APB bus
```

Quy trình:

```text
1. Chọn core: PicoRV32/Ibex/VexRiscv tùy mục tiêu.
2. Viết top-level SoC.
3. Viết testbench mô phỏng boot đơn giản.
4. Test từng peripheral.
5. Tổng hợp bằng Yosys.
6. Chạy OpenLane/OpenROAD.
7. Kiểm tra timing, DRC, LVS.
8. Mở GDS bằng KLayout.
9. Viết tài liệu pinout/test firmware.
10. Nếu có điều kiện, tapeout MPW.
```

---

## 21. Workflow khuyến nghị cho chip mixed-signal nhỏ

Ví dụ:

```text
Digital controller
+ SPI register interface
+ ADC/comparator analog block
+ sensor front-end
```

Quy trình:

```text
1. Thiết kế digital controller bằng Verilog.
2. Mô phỏng digital bằng cocotb/Icarus/Verilator.
3. Thiết kế analog block bằng Xschem.
4. Mô phỏng analog bằng ngspice/Xyce.
5. Layout analog bằng Magic/KLayout.
6. Chạy LVS analog bằng Netgen.
7. Chạy OpenLane cho digital block.
8. Tích hợp top-level.
9. Chạy DRC/LVS toàn chip.
10. Chạy post-layout simulation các đường quan trọng.
```

---

## 22. Các lệnh nhanh cần nhớ

```bash
# Build image
./scripts/build.sh

# Vào terminal container
./scripts/run.sh

# Kiểm tra tool
check-tools
ct

# Chạy demo
counter-demo

# Đổi PDK
source /usr/local/bin/eda-env sky130A
source /usr/local/bin/eda-env gf180mcuD
source /usr/local/bin/eda-env ihp-sg13g2

# Lint Verilog
verilator --lint-only -Wall rtl/top.v

# Sim Verilog
iverilog -g2012 -o sim/top_tb.vvp rtl/top.v sim/top_tb.v
vvp sim/top_tb.vvp

# Yosys synthesis test
yosys -p "read_verilog rtl/top.v; synth -top top; stat"

# Mở GUI
klayout &
xschem &
magic &
gtkwave &
```

---

## 23. Giới hạn pháp lý và kỹ thuật

Bộ Docker này chỉ cài công cụ mã nguồn mở. Nó không cài:

- Cadence Virtuoso.
- Cadence Spectre.
- Cadence Innovus/Genus/Tempus/Pegasus.
- Synopsys Design Compiler/PrimeTime/ICC2/VCS.
- Siemens Calibre/Questa/Tessent.

Nếu bạn có license thương mại, không nên đưa license hoặc installer vào repo công khai. Hãy mount license server hoặc path cài đặt nội bộ theo quy định của nhà cung cấp.

---

## 24. Kết luận

OpenChip Docker Suite giúp bạn có một môi trường EDA mã nguồn mở mạnh để học và triển khai chip thật ở mức nghiên cứu/prototype.

Dùng tốt nhất cho:

```text
RTL design
Verification
Synthesis
Open-source RTL-to-GDS flow
Analog schematic/layout cơ bản
Mixed-signal integration
SKY130/GF180/IHP experimentation
```

Không nên coi đây là bộ thay thế 100% cho signoff thương mại ở advanced node. Cách dùng đúng là:

```text
Open-source stack để học, thiết kế, prototype, exploration
+ commercial signoff nếu làm sản phẩm thương mại nghiêm túc
```

