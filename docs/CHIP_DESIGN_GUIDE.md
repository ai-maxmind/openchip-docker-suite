# CHIP DESIGN GUIDE — HƯỚNG DẪN THIẾT KẾ CHIP BẰNG OPENCHIP DOCKER STACK

> Phạm vi: digital ASIC, IP số, RISC-V/MCU nhỏ, analog block, mixed-signal block, RTL-to-GDSII với SKY130/GF180/IHP SG13G2.  
> Mục tiêu: hướng dẫn người dùng đi từ **ý tưởng chip** đến **RTL, verification, synthesis, layout, STA, DRC/LVS và GDSII**.

---

## 0. Cảnh báo thực tế

Bộ stack này rất mạnh cho học tập, nghiên cứu, prototype, MPW/tapeout thử nghiệm ở các node mở hoặc mature node. Tuy nhiên, nó **không thay thế hoàn toàn commercial signoff** cho chip thương mại advanced-node.

Không kết luận chip đã sẵn sàng sản xuất hàng loạt nếu thiếu:

- PDK được foundry xác nhận.
- Standard-cell library, IO/pad library, SRAM/memory macro đã qualified.
- DRC/LVS/PEX/signoff deck chính thức.
- STA đầy đủ theo corner/mode/variation.
- IR drop, EM, ESD, latch-up, reliability, DFT/ATPG nếu làm chip thương mại.

Triết lý đúng:

```text
Thiết kế chip không phải chỉ là “chạy tool”.
Thiết kế chip = spec đúng + RTL đúng + verification đủ + constraint đúng + layout sạch + timing sạch + DRC/LVS sạch.
```

---

## 1. Stack công cụ dùng trong tài liệu

| Giai đoạn | Công cụ chính | Vai trò |
|---|---|---|
| Spec/architecture | Markdown, YAML, sơ đồ ASCII | Ghi yêu cầu chip, memory map, pinout, clock/reset |
| RTL | Verilog/SystemVerilog | Mô tả logic số |
| Lint | Verilator, Verible | Bắt lỗi coding style, latch, width mismatch |
| Simulation | Icarus Verilog, Verilator, GTKWave | Chạy testbench, xem waveform |
| Python verification | cocotb, pytest, pyuvm | Test tự động, random test, scoreboard |
| Formal | SymbiYosys | Chứng minh property quan trọng |
| Synthesis | Yosys, ABC | RTL → gate-level netlist |
| Timing | OpenSTA | Kiểm tra setup/hold, constraint |
| Physical design | OpenLane/OpenROAD | Floorplan, placement, CTS, routing |
| Layout review | KLayout | Xem DEF/GDS, hierarchy, pin, metal |
| DRC | Magic, KLayout | Kiểm tra design rule |
| LVS | Netgen | So sánh layout-extracted netlist với source netlist |
| Analog schematic | Xschem | Vẽ schematic analog/mixed-signal |
| Analog simulation | ngspice, Xyce | DC/AC/transient/noise simulation |
| Analog layout | Magic, KLayout | Vẽ/kiểm tra layout transistor |
| SRAM | OpenRAM | Sinh SRAM macro và các view cần cho ASIC flow |
| IP management | FuseSoC, Edalize | Quản lý IP, dependency, backend |

---

## 2. Kiểu chip nên thiết kế với stack này

### 2.1. Rất phù hợp

- Counter/test chip.
- UART, SPI, I2C, GPIO, PWM, timer.
- RISC-V MCU nhỏ.
- Digital controller.
- DSP nhỏ.
- Accelerator nhỏ.
- Sensor interface chip.
- Analog block cơ bản: comparator, op-amp, bandgap, oscillator, LDO đơn giản.
- Mixed-signal: MCU + ADC/comparator/AFE.

### 2.2. Không phù hợp nếu chỉ dùng open-source stack

- CPU/GPU/AI accelerator thương mại lớn.
- 7 nm/5 nm/3 nm SoC.
- DRAM/NAND/HBM.
- RF/mmWave 5G/radar cao cấp.
- FPGA fabric thương mại.
- Automotive/power IC cần signoff reliability cực sâu.

---

## 3. Quy trình tổng thể thiết kế chip

```text
Ý tưởng
→ Spec
→ Architecture
→ RTL/Analog schematic
→ Verification
→ Synthesis
→ Floorplan
→ Placement
→ Clock Tree Synthesis
→ Routing
→ Timing analysis
→ DRC
→ LVS
→ GDSII
→ Tapeout package
```

Tư duy kiểm soát:

```text
Mỗi giai đoạn phải có artifact đầu ra.
Mỗi artifact phải có cách kiểm tra.
Không chuyển sang bước sau nếu bước trước còn lỗi nghiêm trọng.
```

---

## 4. Cấu trúc project chip khuyến nghị

```text
my_chip/
├── README.md
├── docs/
│   ├── spec.md
│   ├── architecture.md
│   ├── memory_map.md
│   ├── pinout.md
│   ├── verification_plan.md
│   └── tapeout_checklist.md
├── rtl/
│   ├── top.v
│   ├── core/
│   ├── bus/
│   ├── peripherals/
│   └── include/
├── sim/
│   ├── tb_top.v
│   ├── cocotb/
│   └── waves/
├── formal/
│   ├── properties.sv
│   └── top.sby
├── constraints/
│   ├── top.sdc
│   └── pins.cfg
├── openlane/
│   ├── config.json
│   └── macro_placement.cfg
├── analog/
│   ├── xschem/
│   ├── spice/
│   ├── layout/
│   └── models/
├── macros/
│   ├── sram/
│   └── analog/
├── scripts/
│   ├── lint.sh
│   ├── sim.sh
│   ├── formal.sh
│   ├── synth.sh
│   ├── sta.sh
│   ├── pnr.sh
│   ├── drc.sh
│   └── lvs.sh
├── reports/
│   ├── lint/
│   ├── sim/
│   ├── synth/
│   ├── sta/
│   ├── pnr/
│   ├── drc/
│   └── lvs/
├── runs/
├── gds/
└── Makefile
```

---

## 5. Bước 1 — Viết spec chip

Spec là hợp đồng thiết kế. Nếu spec mơ hồ, chip sẽ sai dù tool chạy sạch.

### 5.1. Nội dung spec tối thiểu

```text
Tên chip:
Mục tiêu:
Node/PDK:
Điện áp:
Clock chính:
Reset:
Số lượng pin:
Giao tiếp:
Bộ nhớ:
Analog block nếu có:
Yêu cầu timing:
Yêu cầu công suất:
Yêu cầu kiểm chứng:
Tiêu chí hoàn thành:
```

### 5.2. Ví dụ spec chip MCU nhỏ

```text
Tên chip: tiny_mcu_sky130
PDK: sky130A
Clock: 25 MHz
Reset: active-low external reset
Core: RISC-V RV32I hoặc controller tự viết
Memory: 4 KB SRAM, 4 KB ROM
Peripheral: GPIO 16-bit, UART, SPI master, timer, PWM
Bus: Wishbone hoặc APB-like bus
Analog: comparator 1 kênh, tùy chọn
Package/pad: dùng padframe có sẵn nếu tapeout
Tiêu chí pass:
- RTL simulation pass
- cocotb tests pass
- Synthesis pass
- STA không vi phạm setup/hold nghiêm trọng ở target clock
- DRC clean
- LVS clean
- GDS mở được bằng KLayout
```

---

## 6. Bước 2 — Chọn PDK

| PDK | Node | Nên dùng khi |
|---|---:|---|
| SKY130 | 130 nm CMOS | Học ASIC, digital/analog cơ bản, MPW thử nghiệm |
| GF180MCU | 180 nm CMOS | MCU, analog, mixed-signal, điện áp cao hơn |
| IHP SG13G2 | 130 nm BiCMOS | Analog/RF/mixed-signal, nghiên cứu nghiêm túc |

Trong container:

```bash
source /usr/local/bin/eda-env sky130A
```

Kiểm tra:

```bash
echo $PDK
echo $PDKPATH
echo $STD_CELL_LIBRARY
ls $PDKPATH
```

Nếu dùng OpenLane, cần đảm bảo `PDK_ROOT`, `PDK`, `STD_CELL_LIBRARY` đúng.

---

## 7. Bước 3 — Thiết kế kiến trúc chip

### 7.1. Kiến trúc digital SoC mẫu

```text
┌───────────────────────────────────────────┐
│                 top_chip                  │
│                                           │
│  ┌─────────────┐      ┌───────────────┐   │
│  │ CPU/Core    │──────│ SRAM/ROM       │   │
│  └──────┬──────┘      └───────────────┘   │
│         │                                 │
│  ┌──────▼─────────────────────────────┐   │
│  │ Bus interconnect: Wishbone/APB      │   │
│  └──────┬───────────────┬─────────────┘   │
│         │               │                 │
│  ┌──────▼─────┐  ┌──────▼────┐ ┌────────┐│
│  │ GPIO       │  │ UART      │ │ Timer  ││
│  └────────────┘  └───────────┘ └────────┘│
│                                           │
│  ┌─────────────────────────────────────┐  │
│  │ Analog macro: comparator/ADC/AFE     │  │
│  └─────────────────────────────────────┘  │
└───────────────────────────────────────────┘
```

### 7.2. Quy tắc phân vùng module

- Mỗi peripheral có module riêng.
- Clock/reset thống nhất.
- Không tạo clock bằng logic nếu chưa hiểu CTS.
- Không dùng `#delay` trong RTL synthesizable.
- Không dùng latch trừ khi chủ đích rất rõ.
- Bus interface phải có handshake rõ ràng.

---

## 8. Bước 4 — Viết RTL synthesizable

### 8.1. Module mẫu: counter có enable

```verilog
module counter #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg [WIDTH-1:0]  count
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= {WIDTH{1'b0}};
    else if (en)
        count <= count + 1'b1;
end

endmodule
```

### 8.2. Quy tắc RTL quan trọng

```text
Dùng non-blocking <= trong always clocked.
Dùng blocking = trong combinational always.
Always combinational phải gán đủ mọi nhánh.
Reset phải nhất quán toàn chip.
Không dùng initial cho logic cần synthesize trừ khi tool/PDK hỗ trợ rõ.
Không trộn nhiều clock lung tung.
Không dùng generated clock nếu chưa có constraint.
```

### 8.3. Lint bằng Verilator

```bash
verilator --lint-only -Wall rtl/top.v
```

Nếu lỗi width:

```text
%Warning-WIDTH
```

Cần sửa rõ ràng bằng cast/slicing/extension, không tắt warning bừa.

---

## 9. Bước 5 — Testbench mô phỏng RTL

### 9.1. Testbench Verilog đơn giản

```verilog
`timescale 1ns/1ps

module tb_counter;
    reg clk = 0;
    reg rst_n = 0;
    reg en = 0;
    wire [7:0] count;

    counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter);

        #20 rst_n = 1;
        #10 en = 1;
        #100 en = 0;
        #20;

        if (count == 10)
            $display("PASS");
        else begin
            $display("FAIL count=%0d", count);
            $finish(1);
        end

        $finish;
    end
endmodule
```

Chạy:

```bash
iverilog -g2012 -o sim/counter_tb.vvp rtl/counter.v sim/tb_counter.v
vvp sim/counter_tb.vvp
gtkwave counter.vcd
```

---

## 10. Bước 6 — Verification bằng cocotb

Dùng cocotb khi muốn test tự động bằng Python, random test, scoreboard, regression.

### 10.1. Test cocotb mẫu

```python
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def counter_basic_test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.en.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    dut.en.value = 1

    for i in range(10):
        await RisingEdge(dut.clk)

    assert int(dut.count.value) == 10
```

### 10.2. Makefile cocotb mẫu

```makefile
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(PWD)/../../rtl/counter.v
TOPLEVEL = counter
MODULE = test_counter
SIM = icarus
include $(shell cocotb-config --makefiles)/Makefile.sim
```

Chạy:

```bash
make
```

---

## 11. Bước 7 — Formal verification bằng SymbiYosys

Formal tốt cho logic điều khiển, FIFO, arbiter, bus protocol, reset behavior.

### 11.1. Property mẫu

```verilog
module counter_formal;
    reg clk;
    reg rst_n;
    reg en;
    wire [7:0] count;

    counter dut (.clk(clk), .rst_n(rst_n), .en(en), .count(count));

    initial begin
        rst_n = 0;
    end

    always @(posedge clk) begin
        if (!rst_n)
            assert(count == 0);
    end
endmodule
```

### 11.2. File `.sby` mẫu

```text
[options]
mode prove

depth 20

[engines]
smtbmc z3

[script]
read_verilog rtl/counter.v formal/counter_formal.v
prep -top counter_formal

[files]
rtl/counter.v
formal/counter_formal.v
```

Chạy:

```bash
sby -f formal/counter.sby
```

---

## 12. Bước 8 — Synthesis bằng Yosys

### 12.1. Synthesis nhanh để kiểm tra RTL

```bash
yosys -p "read_verilog rtl/top.v; synth -top top; stat"
```

### 12.2. Script Yosys có map standard cell

```tcl
read_verilog rtl/top.v
hierarchy -check -top top
proc
opt
fsm
opt
memory
opt
techmap
opt
abc -liberty $::env(LIBERTY_FILE)
clean
stat
write_verilog reports/synth/top_netlist.v
```

Chạy:

```bash
yosys scripts/synth.ys
```

### 12.3. Đọc report synthesis

Cần xem:

```text
Number of cells
Cell type distribution
Estimated area
Warnings
Inferred latch
Undriven wire
Multiple driver
```

Nếu thấy latch không chủ đích, quay lại sửa RTL.

---

## 13. Bước 9 — Viết constraint SDC

Không có SDC đúng thì STA vô nghĩa.

### 13.1. SDC tối thiểu

```tcl
create_clock -name clk -period 40.000 [get_ports clk]
set_input_delay  2.000 -clock clk [all_inputs]
set_output_delay 2.000 -clock clk [all_outputs]
set_false_path -from [get_ports rst_n]
```

`period 40.000` nghĩa là clock 25 MHz.

### 13.2. Quy tắc SDC

```text
Clock phải được khai báo.
Input/output delay phải có giả định hợp lý.
Reset async thường cần false path hoặc constraint riêng.
Multi-cycle path chỉ dùng khi hiểu rõ protocol.
Generated clock phải khai báo nếu có clock divider.
```

---

## 14. Bước 10 — STA bằng OpenSTA

### 14.1. Script OpenSTA mẫu

```tcl
read_liberty $::env(LIBERTY_FILE)
read_verilog reports/synth/top_netlist.v
link_design top
read_sdc constraints/top.sdc
report_checks -path_delay max -fields {slew cap input nets fanout} -digits 3
report_checks -path_delay min -fields {slew cap input nets fanout} -digits 3
report_worst_slack
report_tns
```

Chạy:

```bash
sta scripts/sta.tcl | tee reports/sta/sta.log
```

### 14.2. Đọc timing report

| Chỉ số | Ý nghĩa |
|---|---|
| WNS | Worst Negative Slack |
| TNS | Total Negative Slack |
| Setup violation | Logic quá chậm so với clock |
| Hold violation | Data đến quá sớm |
| Slew | Độ dốc tín hiệu |
| Capacitance | Tải điện dung |
| Fanout | Số cell bị drive |

Nếu WNS âm:

```text
Giảm clock frequency.
Tối ưu RTL.
Thêm pipeline.
Giảm fanout.
Tăng drive strength.
Đổi floorplan/routing.
```

---

## 15. Bước 11 — RTL-to-GDS bằng OpenLane/OpenROAD

### 15.1. Cấu trúc OpenLane tối thiểu

```text
openlane/
└── config.json
```

### 15.2. `config.json` mẫu cho digital block

```json
{
  "DESIGN_NAME": "top",
  "VERILOG_FILES": "dir::../rtl/top.v",
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 40,
  "FP_CORE_UTIL": 45,
  "PL_TARGET_DENSITY": 0.55,
  "DIE_AREA": "0 0 500 500",
  "FP_PDN_MULTILAYER": true,
  "RUN_HEURISTIC_DIODE_INSERTION": true
}
```

Chạy tùy bản OpenLane/LibreLane trong container:

```bash
openlane openlane/config.json
```

Hoặc:

```bash
flow.tcl -design designs/my_chip/openlane
```

Nếu container dùng LibreLane:

```bash
librelane openlane/config.json
```

Kiểm tra tool đang có:

```bash
which openlane
which flow.tcl
which librelane
```

### 15.3. Các bước backend

```text
Synthesis
Floorplan
IO placement
PDN generation
Global placement
Detailed placement
CTS
Global routing
Detailed routing
Fill insertion
Extraction
STA
DRC/LVS
GDS export
```

### 15.4. Report cần đọc sau mỗi run

```text
runs/<run>/reports/synthesis/
runs/<run>/reports/floorplan/
runs/<run>/reports/placement/
runs/<run>/reports/cts/
runs/<run>/reports/routing/
runs/<run>/reports/signoff/
runs/<run>/results/final/gds/
runs/<run>/results/final/def/
runs/<run>/results/final/verilog/
```

---

## 16. Bước 12 — Xem layout bằng KLayout

Mở GDS:

```bash
klayout runs/<run>/results/final/gds/top.gds &
```

Cần kiểm tra bằng mắt:

```text
Die/core đúng kích thước.
Pin nằm đúng vị trí.
Power ring/strap có vẻ hợp lý.
Không có macro chồng lấn.
Không có khoảng trống bất thường.
Routing không bị cắt kỳ lạ.
Hierarchy đúng.
```

Không thay thế DRC/LVS bằng mắt. KLayout chỉ giúp phát hiện lỗi trực quan nhanh.

---

## 17. Bước 13 — DRC bằng Magic/KLayout

### 17.1. DRC với Magic

Ví dụ:

```bash
magic -dnull -noconsole <<'EOF'
gds read top.gds
load top
drc check
drc count
drc why
quit
EOF
```

### 17.2. DRC với KLayout

Nếu có rule deck `.lydrc`:

```bash
klayout -b -r sky130_drc.lydrc -rd input=top.gds -rd report=reports/drc/top.lyrdb
```

### 17.3. Cách xử lý DRC

| Lỗi | Hướng xử lý |
|---|---|
| Spacing | Tăng khoảng cách, giảm density, kiểm tra routing layer |
| Width | Kiểm tra minimum width, power strap, manual route |
| Enclosure | Kiểm tra via/contact/enclosure rule |
| Density | Thêm fill hoặc chỉnh fill insertion |
| Antenna | Chèn diode, đổi routing, thêm jumper |

---

## 18. Bước 14 — LVS bằng Netgen

LVS kiểm tra layout có đúng mạch logic/schematic không.

### 18.1. Nguyên tắc LVS

```text
Netlist layout-extracted phải tương đương netlist source.
Tên pin top-level phải khớp.
Power/ground net phải khớp.
Blackbox macro phải được khai báo đúng.
```

### 18.2. Lệnh LVS mẫu

```bash
netgen -batch lvs \
  "layout.spice top" \
  "source.spice top" \
  setup.tcl \
  reports/lvs/top_lvs.log
```

### 18.3. Lỗi LVS thường gặp

| Triệu chứng | Nguyên nhân |
|---|---|
| Pin mismatch | Tên pin khác nhau giữa layout/source |
| Device mismatch | Layout extract thiếu/sai device |
| Net mismatch | Short/open trong routing/layout |
| Subckt mismatch | Blackbox macro khai báo sai |
| Power mismatch | VDD/VSS tên không thống nhất |

---

## 19. Thiết kế analog block bằng Xschem + ngspice/Xyce + Magic/KLayout

### 19.1. Quy trình analog

```text
Spec analog
→ Schematic Xschem
→ DC simulation
→ AC simulation
→ Transient simulation
→ Noise/corner nếu có
→ Layout Magic/KLayout
→ Extraction
→ LVS
→ Post-layout simulation
→ GDS macro
```

### 19.2. Ví dụ spec comparator

```text
Input range: 0.2 V đến 1.6 V
Supply: 1.8 V
Offset mục tiêu: < 10 mV nếu có thể
Load: digital input hoặc buffer
Output: logic-level compatible
```

### 19.3. Chạy Xschem

```bash
xschem &
```

Trong Xschem:

```text
Vẽ schematic.
Đặt model PDK.
Đặt nguồn VDD/VSS.
Đặt stimulus.
Xuất SPICE netlist.
Chạy ngspice.
```

### 19.4. Ngspice deck mẫu

```spice
.control
op
tran 1n 1u
plot v(out)
.endc
```

Chạy:

```bash
ngspice analog/spice/comparator_tb.spice
```

### 19.5. Checklist analog trước layout

```text
[ ] DC operating point hợp lý
[ ] Bias current hợp lý
[ ] Output swing đạt yêu cầu
[ ] Gain/bandwidth đạt yêu cầu nếu là amplifier
[ ] Transient không dao động ngoài ý muốn
[ ] Input/output common-mode đúng
[ ] Corner simulation nếu có model
```

---

## 20. Tích hợp mixed-signal

Mixed-signal là phần khó vì phải ghép digital flow và analog custom flow.

### 20.1. Nguyên tắc tích hợp

```text
Analog block được coi như macro.
Digital backend cần LEF + GDS + Verilog stub của analog macro.
LVS cần SPICE/CDL view của analog macro.
Simulation cần behavioral model nếu không muốn sim transistor quá nặng.
```

### 20.2. File cần cho một analog macro

```text
comparator.gds       Layout final
comparator.lef       Abstract view cho P&R
comparator.spice     Netlist transistor cho LVS/simulation
comparator.v         Verilog blackbox/behavioral model
comparator.lib       Timing/power nếu digital cần timing chính xác
```

### 20.3. Verilog blackbox mẫu

```verilog
module comparator_macro (
    input  wire vdd,
    input  wire vss,
    input  wire inp,
    input  wire inn,
    output wire out
);
endmodule
```

### 20.4. Behavioral model đơn giản cho sim digital

```verilog
module comparator_model (
    input  real inp,
    input  real inn,
    output reg out
);
always @(*) begin
    out = (inp > inn);
end
endmodule
```

Lưu ý: Verilog real model dùng cho verification hành vi, không dùng cho synthesis.

---

## 21. Dùng OpenRAM cho SRAM macro

### 21.1. Khi nào dùng SRAM macro

Không nên tự synthesize memory lớn bằng flip-flop vì diện tích sẽ rất lớn.

Dùng SRAM macro khi:

```text
Memory > vài trăm bit.
Cần area nhỏ hơn.
Cần timing/power gần thực tế hơn.
```

### 21.2. Artifact cần từ SRAM

```text
SRAM .gds
SRAM .lef
SRAM .lib
SRAM .spice/.cdl
SRAM .v blackbox
```

### 21.3. Tích hợp SRAM vào OpenLane

Cần khai báo macro. Ví dụ cú pháp tổng quát:

```json
{
  "MACROS": {
    "sram_1rw1r_32x1024_8": {
      "gds": ["dir::../macros/sram/sram.gds"],
      "lef": ["dir::../macros/sram/sram.lef"],
      "lib": ["dir::../macros/sram/sram.lib"],
      "instances": {
        "u_sram": {
          "location": [100, 100],
          "orientation": "N"
        }
      }
    }
  }
}
```

Tùy phiên bản OpenLane/LibreLane, cú pháp macro có thể khác. Luôn xem schema config của phiên bản đang dùng.

---

## 22. Thiết kế padframe và IO

Padframe là phần dễ bị xem nhẹ nhưng cực kỳ quan trọng.

### 22.1. Cần xác định

```text
Số lượng pin.
Loại pin: input/output/inout/analog/power/ground.
Điện áp IO.
ESD requirement.
Pad pitch.
Package bonding.
Power pad count.
Reset/clock/test pins.
```

### 22.2. Pinout mẫu

| Pin | Tên | Loại | Mô tả |
|---:|---|---|---|
| 1 | VDD | power | Core supply |
| 2 | VSS | ground | Ground |
| 3 | clk | input | Clock |
| 4 | rst_n | input | Reset active-low |
| 5 | uart_tx | output | UART transmit |
| 6 | uart_rx | input | UART receive |
| 7–22 | gpio[15:0] | inout | GPIO |

### 22.3. Lưu ý

```text
Không nối core logic trực tiếp ra pad nếu cần IO cell.
Không quên ESD/power clamp nếu tapeout thật.
Analog pad cần cách ly noise từ digital.
Clock pad nên có đường routing rõ ràng.
```

---

## 23. Power planning

Power grid sai có thể làm chip chết dù logic đúng.

### 23.1. Cần có

```text
VDD/VSS ring hoặc straps.
Power pins nối đúng standard cell rails.
Macro power pins được connect.
Decap/fill nếu flow hỗ trợ.
Power pad đủ số lượng nếu top chip.
```

### 23.2. Dấu hiệu lỗi power planning

```text
LVS fail do VDD/VSS mismatch.
Cell rail không nối.
Macro báo unconnected power pin.
Routing congestion quanh macro.
IR drop lớn nếu có phân tích.
```

---

## 24. Clock/reset strategy

### 24.1. Clock

```text
Một clock chính cho thiết kế đầu tiên.
Không gate clock bằng logic thường.
Nếu cần enable, dùng clock enable.
Nếu nhiều clock domain, phải có CDC.
```

### 24.2. Reset

```text
Active-high hoặc active-low, không trộn tùy tiện.
Async reset phải được constraint đúng.
Sync reset dễ STA hơn.
Reset release phải sạch.
```

### 24.3. Ví dụ reset synchronizer

```verilog
module reset_sync (
    input  wire clk,
    input  wire rst_n_async,
    output wire rst_n_sync
);
    reg [1:0] sync;

    always @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async)
            sync <= 2'b00;
        else
            sync <= {sync[0], 1'b1};
    end

    assign rst_n_sync = sync[1];
endmodule
```

---

## 25. Debug flow theo triệu chứng

### 25.1. RTL sim pass nhưng synthesis fail

Nguyên nhân thường gặp:

```text
Dùng construct không synthesizable.
Multiple drivers.
Latch không chủ đích.
Memory không infer được.
SystemVerilog feature không được Yosys hỗ trợ đầy đủ.
```

Cách xử lý:

```bash
verilator --lint-only -Wall rtl/top.v
yosys -p "read_verilog -sv rtl/top.sv; hierarchy -check -top top; proc; opt; check"
```

### 25.2. Synthesis pass nhưng OpenLane fail placement

Nguyên nhân:

```text
Die quá nhỏ.
Utilization quá cao.
Macro placement sai.
Pin placement gây congestion.
Standard cell library/PDK path sai.
```

Cách xử lý:

```text
Tăng DIE_AREA.
Giảm FP_CORE_UTIL.
Giảm PL_TARGET_DENSITY.
Đặt macro thủ công.
Xem congestion report.
```

### 25.3. Routing fail

```text
Congestion cao.
Pin quá dày một cạnh.
Macro chặn routing.
Power grid quá dày.
Core quá nhỏ.
```

Cách xử lý:

```text
Tăng die/core size.
Phân bổ pin đều hơn.
Dịch macro.
Giảm utilization.
Cho phép dùng thêm routing layers nếu PDK hỗ trợ.
```

### 25.4. STA fail setup

```text
1. Kiểm tra SDC đúng chưa.
2. Kiểm tra clock period có quá tham vọng không.
3. Xem path chậm nhất.
4. Pipeline path dài.
5. Giảm fanout hoặc thêm buffer.
6. Thay đổi synthesis strategy.
7. Tăng drive strength nếu tool hỗ trợ.
```

### 25.5. STA fail hold

```text
Kiểm tra generated clock/false path sai không.
Cho backend insert delay/buffer.
Không sửa hold bằng cách đổi RTL bừa nếu không rõ nguyên nhân.
```

### 25.6. DRC fail

```text
Mở report trong KLayout/Magic.
Xác định rule nào fail.
Nếu lỗi từ auto-route: chỉnh flow.
Nếu lỗi từ macro: sửa macro.
Nếu lỗi từ manual layout: sửa geometry.
```

### 25.7. LVS fail

```text
So pin top-level.
So power/ground names.
Kiểm tra blackbox macro.
Kiểm tra net short/open.
Kiểm tra extracted netlist.
```

---

## 26. Makefile mẫu cho project chip

```makefile
DESIGN=top
RTL=rtl/top.v
TB=sim/tb_top.v

.PHONY: all lint sim synth sta clean

all: lint sim synth

lint:
	verilator --lint-only -Wall $(RTL)

sim:
	mkdir -p reports/sim
	iverilog -g2012 -o reports/sim/$(DESIGN)_tb.vvp $(RTL) $(TB)
	vvp reports/sim/$(DESIGN)_tb.vvp

synth:
	mkdir -p reports/synth
	yosys -p "read_verilog $(RTL); synth -top $(DESIGN); stat; write_verilog reports/synth/$(DESIGN)_netlist.v" | tee reports/synth/yosys.log

sta:
	mkdir -p reports/sta
	sta scripts/sta.tcl | tee reports/sta/sta.log

clean:
	rm -rf reports/sim/*.vvp reports/synth/*.v reports/*.vcd
```

---

## 27. Tiêu chuẩn hoàn thành theo từng cấp

### 27.1. Digital IP hoàn thành

```text
[ ] Spec có mô tả input/output/protocol.
[ ] RTL lint sạch hoặc warning đã giải thích.
[ ] Simulation pass.
[ ] cocotb/pytest pass nếu có.
[ ] Formal pass cho property quan trọng nếu có.
[ ] Synthesis pass.
[ ] Không có inferred latch ngoài ý muốn.
[ ] Timing sơ bộ hợp lý.
```

### 27.2. Digital block layout hoàn thành

```text
[ ] OpenLane/OpenROAD run hoàn thành.
[ ] DEF/GDS sinh ra được.
[ ] STA post-route không vi phạm nghiêm trọng.
[ ] DRC clean hoặc còn lỗi đã phân loại.
[ ] LVS clean.
[ ] GDS mở bằng KLayout không có lỗi trực quan.
```

### 27.3. Analog block hoàn thành

```text
[ ] Schematic simulation pass.
[ ] Layout hoàn chỉnh.
[ ] DRC clean.
[ ] LVS clean.
[ ] Extraction xong.
[ ] Post-layout simulation pass.
[ ] GDS/LEF/SPICE view sẵn sàng tích hợp.
```

### 27.4. Mixed-signal chip hoàn thành

```text
[ ] Digital top pass RTL simulation.
[ ] Analog macro pass schematic/post-layout simulation.
[ ] Macro LEF/GDS/SPICE/Verilog stub đồng bộ.
[ ] Top-level integration pass.
[ ] Top-level DRC/LVS clean.
[ ] Pinout/padframe kiểm tra xong.
[ ] Tapeout checklist hoàn thành.
```

---

## 28. Lộ trình thực hành 30 ngày

### Tuần 1 — Digital RTL/IP

| Ngày | Mục tiêu |
|---:|---|
| 1 | Chạy container, check-tools, counter-demo |
| 2 | Viết counter/timer, test bằng Icarus |
| 3 | Lint Verilator, sửa toàn bộ warning |
| 4 | Xem waveform bằng GTKWave |
| 5 | Viết cocotb test cho counter/timer |
| 6 | Viết UART TX đơn giản |
| 7 | Synthesis bằng Yosys, đọc report |

### Tuần 2 — Verification + synthesis nghiêm túc

| Ngày | Mục tiêu |
|---:|---|
| 8 | Viết FIFO nhỏ |
| 9 | Viết formal property cho FIFO |
| 10 | Viết bus register block |
| 11 | Test register block bằng cocotb |
| 12 | Viết SDC cơ bản |
| 13 | Chạy OpenSTA trên netlist |
| 14 | Tối ưu RTL để giảm critical path |

### Tuần 3 — RTL-to-GDS

| Ngày | Mục tiêu |
|---:|---|
| 15 | Tạo OpenLane config cho block nhỏ |
| 16 | Chạy floorplan/placement/routing |
| 17 | Đọc report OpenLane/OpenROAD |
| 18 | Mở GDS bằng KLayout |
| 19 | Debug DRC cơ bản |
| 20 | Debug LVS cơ bản |
| 21 | Tạo layout clean cho digital block |

### Tuần 4 — Analog/mixed-signal và top integration

| Ngày | Mục tiêu |
|---:|---|
| 22 | Vẽ inverter/comparator trong Xschem |
| 23 | Chạy ngspice DC/transient |
| 24 | Vẽ layout analog đơn giản bằng Magic/KLayout |
| 25 | Chạy LVS analog bằng Netgen |
| 26 | Tạo Verilog stub cho analog macro |
| 27 | Tích hợp macro vào digital top |
| 28 | Tạo top-level GDS |
| 29 | Chạy checklist DRC/LVS/STA |
| 30 | Đóng gói báo cáo thiết kế chip |

---

## 29. Template báo cáo thiết kế chip

Khi hoàn thành một design, viết báo cáo theo mẫu:

```text
1. Tên chip/block
2. Mục tiêu
3. PDK/node
4. Kiến trúc
5. Sơ đồ module
6. Clock/reset
7. Memory map
8. Pinout
9. Verification plan
10. Simulation result
11. Formal result nếu có
12. Synthesis report
13. STA report
14. Floorplan/layout screenshot
15. DRC report
16. LVS report
17. Known issues
18. Next revision plan
```

---

## 30. Bộ lệnh nhanh

```bash
# Vào container
./scripts/run.sh

# Kiểm tra tool
check-tools

# Chọn PDK
source /usr/local/bin/eda-env sky130A

# Lint RTL
verilator --lint-only -Wall rtl/top.v

# Sim RTL
iverilog -g2012 -o sim/top_tb.vvp rtl/top.v sim/tb_top.v
vvp sim/top_tb.vvp

# Xem waveform
gtkwave dump.vcd

# Synthesis nhanh
yosys -p "read_verilog rtl/top.v; synth -top top; stat"

# STA
sta scripts/sta.tcl

# OpenLane/OpenROAD flow
openlane openlane/config.json

# Xem GDS
klayout runs/<run>/results/final/gds/top.gds &

# Analog schematic
xschem &

# Analog simulation
ngspice analog/spice/testbench.spice

# Layout
magic &
klayout &
```

---

## 31. Checklist cuối trước khi xuất GDS

```text
[ ] Spec đã đóng băng.
[ ] RTL đúng version.
[ ] Testbench pass.
[ ] cocotb regression pass.
[ ] Formal pass nếu có.
[ ] Synthesis pass.
[ ] SDC đúng.
[ ] STA setup/hold hợp lý.
[ ] OpenROAD/OpenLane run hoàn thành.
[ ] Antenna check pass hoặc đã xử lý.
[ ] DRC clean.
[ ] LVS clean.
[ ] GDS mở được bằng KLayout.
[ ] Pinout kiểm tra xong.
[ ] Power/ground kiểm tra xong.
[ ] Macro view đồng bộ.
[ ] Báo cáo thiết kế đã lưu.
[ ] Tool version/PDK version đã ghi lại.
```

---

## 32. Kết luận

Thiết kế chip bằng OpenChip Docker Stack nên đi theo phương pháp có kỷ luật:

```text
Spec rõ
→ RTL/analog đúng
→ verification đủ
→ synthesis sạch
→ layout hợp lệ
→ timing sạch
→ DRC/LVS sạch
→ GDSII có kiểm soát
```

Đừng bắt đầu bằng chip lớn. Lộ trình hiệu quả nhất:

```text
Counter
→ UART/GPIO/Timer
→ Bus + peripheral
→ RISC-V MCU nhỏ
→ SRAM macro
→ Analog comparator
→ Mixed-signal top
→ GDSII clean
```

