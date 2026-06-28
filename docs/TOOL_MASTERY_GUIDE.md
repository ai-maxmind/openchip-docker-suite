# TOOL MASTERY GUIDE — HƯỚNG DẪN THÀNH THẠO BỘ STACK THIẾT KẾ CHIP MÃ NGUỒN MỞ

Bộ stack này không phải là một phần mềm đơn lẻ. Nó là một **hệ sinh thái EDA** gồm nhiều công cụ chuyên trách:

```text
RTL/spec
→ lint/simulation/formal
→ synthesis
→ physical design
→ timing
→ physical verification
→ analog simulation/layout
→ GDSII/tapeout package
```

Muốn thành thạo, không học rời rạc từng lệnh. Phải học theo 4 lớp:

1. **Tool command**: biết lệnh chạy.
2. **Artifact**: hiểu file đầu vào/đầu ra: `.v`, `.sdc`, `.lib`, `.lef`, `.def`, `.spef`, `.gds`, `.spice`, `.mag`, `.cdl`.
3. **Failure mode**: biết lỗi sai nằm ở RTL, constraint, PDK, placement, routing, timing, DRC hay LVS.
4. **Flow integration**: biết tool này đưa dữ liệu sang tool tiếp theo như thế nào.

---

## 1. Sơ đồ vai trò toàn bộ tool

| Nhóm | Tool | Mục tiêu thành thạo |
|---|---|---|
| HDL lint/sim | Verilator | Bắt lỗi RTL sớm, mô phỏng nhanh, lint SystemVerilog |
| HDL sim | Icarus Verilog | Mô phỏng Verilog đơn giản, sinh VCD |
| VHDL sim | GHDL | Mô phỏng VHDL, phối hợp mixed-language cơ bản |
| Python verification | cocotb, pyuvm, pytest | Viết testbench tự kiểm tra bằng Python |
| Formal | SymbiYosys, Yosys-SMTBMC | Chứng minh property, tìm bug trạng thái hiếm |
| Synthesis | Yosys, ABC | Chuyển RTL sang gate-level netlist |
| Backend | OpenROAD, OpenLane/LibreLane | Floorplan, placement, CTS, routing, GDS |
| Timing | OpenSTA | Kiểm tra setup/hold, clock, path, constraint |
| Layout | Magic | Layout, extraction, DRC cho open PDK |
| Layout viewer/DRC | KLayout | Xem GDS, DRC script, inspection, hierarchy |
| LVS | Netgen | So sánh schematic/netlist với layout-extracted netlist |
| Analog schematic | Xschem | Vẽ schematic, xuất SPICE netlist |
| Circuit sim | ngspice, Xyce | Mô phỏng DC/AC/transient/noise/corner cơ bản |
| Memory | OpenRAM | Sinh SRAM macro và các view cho ASIC flow |
| Waveform | GTKWave | Đọc VCD/FST, debug tín hiệu |
| Meta-build | FuseSoC, Edalize | Quản lý IP, dependency, backend tool |
| Formatting/lint | Verible, sv2v, Surelog | Chuẩn hóa SystemVerilog, chuyển đổi, parse nâng cao |

---

## 2. Cấp độ thành thạo

### Level 1 — Chạy được

Bạn phải làm được:

```bash
check-tools
counter-demo
verilator --lint-only -Wall rtl/top.v
iverilog -g2012 -o sim/top_tb.vvp rtl/top.v sim/top_tb.v
vvp sim/top_tb.vvp
yosys -p "read_verilog rtl/top.v; synth -top top; stat"
```

### Level 2 — Debug được

Bạn phải trả lời được:

- Lỗi này do syntax, simulation mismatch hay RTL không synthesizable?
- Vì sao Yosys infer latch?
- Vì sao timing WNS âm?
- Vì sao DRC sạch nhưng LVS fail?
- Vì sao post-layout simulation khác pre-layout?

### Level 3 — Tự tạo flow được

Bạn phải viết được:

- `Makefile` chạy lint/sim/synth.
- `config.json` cho OpenLane/OpenROAD.
- `top.sdc` mô tả clock/input/output delay.
- Script OpenSTA Tcl.
- Script ngspice cho DC/AC/transient.

### Level 4 — Thiết kế chip nhỏ hoàn chỉnh

Bạn phải tự làm được:

- RISC-V MCU nhỏ hoặc peripheral SoC.
- Macro SRAM hoặc ROM.
- GDS mở được bằng KLayout.
- DRC/LVS/STA sạch ở mức open-source flow.
- Báo cáo area/timing/power/routing rõ ràng.

---

# PHẦN A — DIGITAL FRONTEND

---

## 3. Verilator — lint và simulation nhanh

### 3.1. Vai trò

Verilator dùng để:

- Lint Verilog/SystemVerilog.
- Biên dịch RTL sang C++/SystemC model.
- Mô phỏng nhanh thiết kế digital.
- Hỗ trợ assertion/coverage ở mức phù hợp.

Không nên dùng Yosys làm công cụ kiểm tra syntax chính. Hãy lint bằng Verilator trước khi synthesis.

### 3.2. Lệnh cơ bản

Lint một file:

```bash
verilator --lint-only -Wall rtl/top.v
```

Lint nhiều file:

```bash
verilator --lint-only -Wall -sv \
  rtl/pkg.sv \
  rtl/fifo.sv \
  rtl/top.sv
```

Bỏ qua một số warning không quan trọng:

```bash
verilator --lint-only -Wall -Wno-UNUSED -Wno-DECLFILENAME rtl/top.v
```

Xuất XML để tool khác phân tích:

```bash
verilator --xml-only -sv rtl/top.sv
```

### 3.3. Warning quan trọng

| Warning | Ý nghĩa | Cách xử lý |
|---|---|---|
| `LATCH` | logic tổ hợp thiếu nhánh gán | gán default trong `always_comb` |
| `WIDTH` | sai độ rộng bit | ép width rõ ràng |
| `UNDRIVEN` | tín hiệu không được drive | kiểm tra reset/assign |
| `UNUSED` | tín hiệu không dùng | xóa hoặc comment rõ |
| `MULTIDRIVEN` | nhiều nguồn drive một net | sửa kiến trúc assign |
| `CASEINCOMPLETE` | case thiếu nhánh | thêm `default` |

### 3.4. Quy tắc RTL để Verilator sạch

Nên viết:

```systemverilog
always_comb begin
    y = '0;
    unique case (sel)
        2'd0: y = a;
        2'd1: y = b;
        2'd2: y = c;
        default: y = d;
    endcase
end
```

Không nên viết:

```verilog
always @(*) begin
    if (en)
        y = a;
end
```

Vì dễ tạo latch.

### 3.5. Bài tập thành thạo

1. Viết counter 8-bit, chạy lint không warning nghiêm trọng.
2. Cố ý tạo latch, quan sát warning.
3. Cố ý sai width, sửa lại.
4. Viết FIFO nhỏ, lint bằng Verilator.
5. Tạo script `scripts/lint.sh` chạy toàn bộ RTL.

---

## 4. Icarus Verilog — simulation đơn giản

### 4.1. Vai trò

Icarus Verilog phù hợp để:

- Mô phỏng Verilog nhỏ.
- Chạy testbench HDL truyền thống.
- Sinh waveform VCD cho GTKWave.

### 4.2. Lệnh cơ bản

```bash
iverilog -g2012 -o build/top_tb.vvp rtl/top.v sim/top_tb.v
vvp build/top_tb.vvp
```

Sinh VCD trong testbench:

```verilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_tb);
end
```

Mở waveform:

```bash
gtkwave dump.vcd
```

### 4.3. Testbench mẫu

```verilog
`timescale 1ns/1ps

module counter_tb;
    reg clk = 0;
    reg rst_n = 0;
    wire [7:0] count;

    counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (20) @(posedge clk);

        if (count != 8'd20) begin
            $display("FAIL: count=%0d", count);
            $finish(1);
        end

        $display("PASS");
        $finish;
    end
endmodule
```

### 4.4. Bài tập thành thạo

- Viết testbench tự check cho counter.
- Viết testbench FIFO: push, pop, full, empty.
- Sinh VCD và đánh dấu clock/reset/data trong GTKWave.

---

## 5. GTKWave — debug waveform

### 5.1. Vai trò

GTKWave dùng để xem tín hiệu VCD/FST/LXT.

### 5.2. Lệnh cơ bản

```bash
gtkwave dump.vcd
```

Lưu cấu hình signal:

```text
File → Write Save File
```

Mở lại:

```bash
gtkwave dump.vcd view.gtkw
```

### 5.3. Kỹ năng cần có

- Group tín hiệu theo block.
- Đổi radix: binary/hex/decimal/signed.
- Tìm cạnh clock.
- Tìm thời điểm reset release.
- So sánh expected vs actual.
- Đọc bus handshake: valid/ready.

---

## 6. cocotb + pytest — verification bằng Python

### 6.1. Vai trò

cocotb cho phép viết testbench bằng Python thay vì HDL. Đây là cách rất mạnh để:

- Tạo random test.
- So sánh với golden model Python.
- Dùng pytest regression.
- Dễ viết scoreboard/monitor/driver.

### 6.2. Cấu trúc project cocotb

```text
sim/cocotb/
├── test_counter.py
├── Makefile
└── conftest.py  # tùy chọn
```

### 6.3. Test cocotb mẫu

```python
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def counter_counts_up(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    for i in range(10):
        await RisingEdge(dut.clk)

    assert int(dut.count.value) == 10
```

### 6.4. Makefile cocotb mẫu

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

### 6.5. Kỹ năng thành thạo

- Viết driver cho bus.
- Viết monitor đọc output.
- Viết scoreboard so sánh expected/actual.
- Random hóa input có seed.
- Chạy regression bằng pytest.
- Chia test thành nhiều case nhỏ.

### 6.6. Bài tập

1. Viết cocotb test cho UART TX.
2. Viết FIFO random push/pop.
3. Viết ALU test so sánh với model Python.
4. Tạo regression 100 seed.

---

## 7. pyuvm — UVM phong cách Python

### 7.1. Vai trò

pyuvm phù hợp khi testbench bắt đầu lớn. Nó cho cách tổ chức:

- sequence.
- driver.
- monitor.
- scoreboard.
- environment.
- agent.

### 7.2. Khi nào dùng pyuvm?

Dùng khi:

- Có nhiều interface.
- Có giao thức bus.
- Cần reusable verification component.
- Testbench cocotb thuần bắt đầu rối.

Không cần dùng cho module nhỏ như counter.

### 7.3. Cấu trúc tư duy

```text
sequence item → sequence → driver → DUT
DUT → monitor → scoreboard
```

---

## 8. SymbiYosys — formal verification

### 8.1. Vai trò

Formal không chạy test theo vector. Nó chứng minh property đúng với mọi trạng thái trong phạm vi kiểm tra.

Dùng tốt cho:

- FIFO full/empty.
- Counter không overflow sai.
- Arbiter fairness cơ bản.
- Handshake valid/ready.
- One-hot FSM.
- Không đọc khi FIFO empty.
- Không ghi khi FIFO full.

### 8.2. File `.sby` mẫu

```ini
[options]
mode prove
depth 20

[engines]
smtbmc z3

[script]
read -formal rtl/fifo.v
prep -top fifo

[files]
rtl/fifo.v
```

Chạy:

```bash
sby -f formal/fifo.sby
```

### 8.3. Assertion mẫu

```systemverilog
always @(posedge clk) begin
    if (rst_n) begin
        assert(!(rd_en && empty));
        assert(!(wr_en && full));
    end
end
```

### 8.4. Cover property

```systemverilog
always @(posedge clk) begin
    cover(full);
    cover(empty);
end
```

### 8.5. Bài tập

1. Chứng minh counter reset về 0.
2. Chứng minh FIFO không underflow.
3. Chứng minh one-hot FSM luôn one-hot.
4. Tạo counterexample rồi mở waveform debug.

---

# PHẦN B — SYNTHESIS

---

## 9. Yosys — tổng hợp RTL sang gate-level netlist

### 9.1. Vai trò

Yosys nhận RTL và tạo netlist đã map sang cell library. Trong open-source flow, Yosys là xương sống của synthesis.

### 9.2. Lệnh nhanh

```bash
yosys -p "read_verilog rtl/top.v; synth -top top; stat"
```

Với SystemVerilog:

```bash
yosys -p "read_verilog -sv rtl/top.sv; synth -top top; stat"
```

### 9.3. Script synthesis mẫu

Tạo `scripts/synth.ys`:

```tcl
read_verilog -sv rtl/top.sv
hierarchy -check -top top
proc
opt
fsm
opt
memory
opt
techmap
opt
abc -liberty $::env(STD_CELL_LIB)
clean
stat
write_verilog -noattr build/top_synth.v
```

Chạy:

```bash
yosys scripts/synth.ys
```

### 9.4. Các pass quan trọng

| Pass | Ý nghĩa |
|---|---|
| `read_verilog` | đọc RTL |
| `hierarchy -check -top` | xác định top module, kiểm tra module thiếu |
| `proc` | chuyển always/process thành netlist trung gian |
| `opt` | tối ưu logic |
| `fsm` | nhận diện/tối ưu FSM |
| `memory` | xử lý memory/infer memory |
| `techmap` | map logic generic |
| `abc` | map sang standard cell |
| `stat` | báo area/cell count |
| `write_verilog` | xuất netlist |

### 9.5. Lỗi thường gặp

| Lỗi | Nguyên nhân | Cách xử lý |
|---|---|---|
| Module not found | thiếu file RTL | thêm file vào script |
| Latch inferred | always tổ hợp thiếu default | sửa RTL |
| Multiple drivers | nhiều always/assign drive cùng net | sửa architecture |
| Unsupported SV feature | dùng feature SystemVerilog chưa hỗ trợ | dùng sv2v/Surelog hoặc viết RTL đơn giản hơn |
| Memory not mapped | RAM không phù hợp standard cells/macro | dùng macro/OpenRAM hoặc rewrite |

### 9.6. Quy tắc RTL synthesizable

Nên dùng:

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        q <= '0;
    else
        q <= d;
end
```

```systemverilog
always_comb begin
    y = '0;
    if (en)
        y = a & b;
end
```

Tránh:

- `#delay` trong RTL synthesizable.
- `initial` cho logic production, trừ memory init có flow hỗ trợ.
- Dynamic array, class, mailbox trong RTL.
- Clock gated thủ công chưa kiểm soát.

---

## 10. ABC — logic optimization/mapping

### 10.1. Vai trò

ABC thường được Yosys gọi bên trong để tối ưu/mapping logic tổ hợp sang standard cell.

### 10.2. Khi nào cần gọi ABC trực tiếp?

Hiếm khi cần. Nhưng nên hiểu vì ABC ảnh hưởng:

- cell mapping.
- depth/timing.
- area.
- logic optimization.

### 10.3. Trong Yosys

```tcl
abc -liberty path/to/cells.lib
```

Nếu muốn ưu tiên timing:

```tcl
abc -D 1000 -liberty path/to/cells.lib
```

`-D` là delay target theo đơn vị nội bộ, cần thử nghiệm theo library.

---

# PHẦN C — CONSTRAINT VÀ TIMING

---

## 11. SDC — file constraint bắt buộc phải hiểu

### 11.1. Vai trò

SDC nói cho tool biết:

- Clock period.
- Input/output delay.
- False path.
- Multicycle path.
- Clock uncertainty.
- Load/drive.

Không có SDC đúng thì timing report gần như vô nghĩa.

### 11.2. SDC mẫu

```tcl
create_clock -name clk -period 10.000 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

set_input_delay 2.0 -clock [get_clocks clk] [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 2.0 -clock [get_clocks clk] [all_outputs]

set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [all_inputs]
set_load 0.05 [all_outputs]
```

### 11.3. Những lỗi SDC nguy hiểm

| Lỗi | Hậu quả |
|---|---|
| Không tạo clock | STA không kiểm tra path synchronous |
| Sai period | chip không chạy đúng frequency mục tiêu |
| Không set IO delay | report quá lạc quan |
| False path quá rộng | che giấu lỗi timing |
| Multicycle sai | tapeout rủi ro cao |

---

## 12. OpenSTA — static timing analysis

### 12.1. Vai trò

OpenSTA kiểm tra timing gate-level bằng `.lib`, netlist, SDC, SPEF/SDF nếu có.

### 12.2. Script STA tối thiểu

`sta/run_sta.tcl`:

```tcl
read_liberty $env(STD_CELL_LIB)
read_verilog build/top_synth.v
link_design top
read_sdc constraints/top.sdc

report_checks -path_delay max -fields {slew cap input_pins net} -digits 4
report_checks -path_delay min -fields {slew cap input_pins net} -digits 4
report_tns
report_wns
report_power
```

Chạy:

```bash
sta sta/run_sta.tcl
```

### 12.3. Đọc timing report

Các khái niệm:

| Thuật ngữ | Ý nghĩa |
|---|---|
| setup | dữ liệu phải đến trước cạnh clock capture |
| hold | dữ liệu không được đổi quá sớm sau cạnh clock launch |
| slack | thời gian dư; âm là fail |
| WNS | worst negative slack |
| TNS | total negative slack |
| slew | độ dốc tín hiệu |
| capacitance | tải net/cell pin |

### 12.4. Cách xử lý setup violation

- Giảm clock frequency.
- Tối ưu RTL pipeline.
- Dùng cell drive mạnh hơn.
- Giảm fanout.
- Buffer critical nets.
- Sửa floorplan để giảm wirelength.
- Tách combinational path quá dài.

### 12.5. Cách xử lý hold violation

- Thêm delay/buffer trên data path.
- Kiểm tra clock skew.
- Không tự sửa bằng delay cell tùy tiện nếu flow chưa kiểm soát.
- Chạy hold repair trong backend flow.

---

# PHẦN D — RTL TO GDSII

---

## 13. OpenLane / LibreLane — flow tự động RTL → GDSII

### 13.1. Vai trò

OpenLane/LibreLane đóng vai trò “flow manager”:

```text
RTL + config + PDK
→ synthesis
→ floorplan
→ placement
→ CTS
→ routing
→ signoff checks
→ GDS/DEF/reports
```

### 13.2. Cấu trúc thiết kế OpenLane

```text
designs/my_chip/
├── config.json
├── src/
│   └── top.v
└── constraints.sdc
```

### 13.3. `config.json` mẫu

```json
{
  "DESIGN_NAME": "top",
  "VERILOG_FILES": ["dir::src/top.v"],
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 10,
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY": 0.55,
  "DIE_AREA": "0 0 500 500",
  "FP_PDN_MULTILAYER": true
}
```

### 13.4. Chạy flow

Tùy phiên bản có thể dùng:

```bash
openlane designs/my_chip/config.json
```

Hoặc dùng script/command của LibreLane nếu image dùng LibreLane.

### 13.5. Report cần đọc

Sau mỗi run, kiểm tra:

```text
runs/<run>/reports/
runs/<run>/logs/
runs/<run>/results/final/gds/
runs/<run>/results/final/def/
runs/<run>/results/final/verilog/
```

Quan trọng nhất:

- synthesis cell count.
- utilization.
- WNS/TNS.
- routing congestion.
- DRC count.
- LVS status.
- antenna status.

### 13.6. Khi flow fail

| Stage fail | Cách khoanh vùng |
|---|---|
| synthesis | chạy Yosys riêng, lint RTL |
| floorplan | xem DIE_AREA/utilization/pin placement |
| placement | giảm density, tăng die area |
| CTS | kiểm tra clock port/reset/gated clock |
| routing | giảm utilization, tăng routing layer, sửa macro placement |
| STA | xem critical path, sửa RTL/constraint |
| DRC | mở GDS bằng KLayout/Magic |
| LVS | kiểm tra netlist, pin name, power/ground |

---

## 14. OpenROAD — backend engine

### 14.1. Vai trò

OpenROAD thực hiện các bước physical design:

- floorplan.
- macro placement.
- IO placement.
- PDN.
- global placement.
- detailed placement.
- CTS.
- global routing.
- detailed routing.
- filler/tapcell.
- SPEF extraction.
- timing repair.

### 14.2. Lệnh OpenROAD

```bash
openroad
```

Chạy Tcl:

```bash
openroad scripts/pnr.tcl
```

### 14.3. Tcl flow mẫu khái niệm

```tcl
read_lef $env(TECH_LEF)
read_lef $env(SC_LEF)
read_def build/floorplan.def
read_liberty $env(STD_CELL_LIB)
read_sdc constraints/top.sdc

initialize_floorplan -utilization 40 -aspect_ratio 1.0
place_pins -hor_layers met3 -ver_layers met2
global_placement
detailed_placement
clock_tree_synthesis
repair_clock_nets
global_route
detailed_route
write_def build/routed.def
write_db build/routed.odb
```

Tên lệnh có thể khác theo version. Khi nghi ngờ, dùng:

```tcl
help
help <command>
```

### 14.4. Chiến thuật debug backend

- Tăng die area nếu routing fail.
- Giảm utilization nếu placement/routing nghẽn.
- Kiểm tra macro halo/channel.
- Đặt pin hợp lý theo hướng kết nối.
- Không để reset/clock đi vòng quá xa.
- Không ép floorplan quá chật.
- Đọc congestion map.

---

# PHẦN E — PHYSICAL VERIFICATION

---

## 15. Magic — layout, DRC, extraction

### 15.1. Vai trò

Magic là layout editor lâu đời, rất hữu ích với open PDK như SKY130/GF180.

Dùng để:

- Xem/sửa layout.
- Chạy DRC.
- Extract parasitic/netlist.
- Xuất GDS.
- Kiểm tra cell/macro.

### 15.2. Mở layout

```bash
magic -T sky130A.tech
```

Hoặc:

```bash
magic -d XR -T path/to/techfile.tech layout.mag
```

### 15.3. Lệnh Magic cơ bản

Trong console Magic:

```tcl
grid
box
select
what
drc check
drc count
drc why
extract all
ext2spice lvs
ext2spice
```

### 15.4. DRC với Magic

```tcl
drc check
drc count
drc why
```

Nếu có lỗi:

- zoom vào marker.
- dùng `drc why` đọc rule.
- sửa spacing/width/enclosure.

### 15.5. Extraction SPICE

```tcl
extract all
ext2spice lvs
ext2spice
```

Đầu ra thường là file `.spice` dùng cho LVS hoặc post-layout simulation.

---

## 16. KLayout — xem GDS, DRC/LVS script

### 16.1. Vai trò

KLayout là tool cực quan trọng để:

- Mở GDS/OASIS.
- Xem hierarchy.
- Inspect layer.
- Chạy DRC script.
- Chạy LVS script.
- Viết script Ruby/Python cho layout automation.

### 16.2. Mở GDS

```bash
klayout results/final/gds/top.gds
```

### 16.3. Kỹ năng cần thành thạo

- Bật/tắt layer.
- Xem cell hierarchy.
- Đo khoảng cách.
- Trace net nếu có connectivity.
- Dùng marker browser.
- Chạy DRC deck.
- Export screenshot cho report.

### 16.4. DRC script khái niệm

```ruby
report("simple_drc")

metal1 = input(68, 20)
metal1.width(0.14.um).output("M1_WIDTH", "Metal1 width violation")
metal1.space(0.14.um).output("M1_SPACE", "Metal1 spacing violation")
```

Chạy:

```bash
klayout -b -r rules/simple_drc.lydrc -rd input=top.gds -rd report=drc.lyrdb
```

---

## 17. Netgen — LVS

### 17.1. Vai trò

Netgen so sánh hai netlist:

```text
schematic/source netlist
vs
layout extracted netlist
```

Nếu không khớp, chip layout không đại diện đúng mạch.

### 17.2. Lệnh LVS khái niệm

```bash
netgen -batch lvs \
  "schematic.spice top" \
  "layout.spice top" \
  setup.tcl \
  lvs_report.out
```

### 17.3. Lỗi LVS thường gặp

| Lỗi | Nguyên nhân |
|---|---|
| pin mismatch | tên pin schematic/layout khác nhau |
| device mismatch | transistor thiếu/thừa/sai W/L |
| net mismatch | short/open trong layout |
| power net mismatch | VDD/VSS đặt tên không thống nhất |
| hierarchy mismatch | flatten/hierarchy khác nhau |

### 17.4. Cách debug LVS

1. Đầu tiên kiểm tra pin name.
2. Kiểm tra power/ground name.
3. So sánh số transistor/cell.
4. Nếu mismatch lớn, có thể sai top cell hoặc sai extraction.
5. Nếu mismatch nhỏ, tìm net bị open/short.

---

# PHẦN F — ANALOG / MIXED-SIGNAL

---

## 18. Xschem — schematic capture

### 18.1. Vai trò

Xschem dùng để vẽ schematic và xuất SPICE netlist.

Phù hợp cho:

- inverter transistor-level.
- current mirror.
- opamp.
- comparator.
- bandgap/LDO cơ bản.
- analog front-end.

### 18.2. Mở Xschem

```bash
xschem
```

Với project:

```bash
xschem schematic/top.sch
```

### 18.3. Quy trình làm schematic

1. Chọn PDK đúng.
2. Đặt transistor/resistor/capacitor.
3. Đặt nguồn, ground, stimulus.
4. Đặt label net rõ ràng.
5. Tạo symbol nếu cần hierarchy.
6. Xuất SPICE netlist.
7. Chạy ngspice.

### 18.4. Nguyên tắc đặt tên net

- Dùng `vdd`, `vss`, `vin`, `vout`, `bias`, `clk` nhất quán.
- Pin top-level phải khớp layout/LVS.
- Không dùng tên mơ hồ như `net1`, `a1` ở top.

---

## 19. ngspice — mô phỏng mạch

### 19.1. Vai trò

ngspice mô phỏng:

- DC operating point.
- DC sweep.
- transient.
- AC small-signal.
- noise.
- Monte Carlo/corner tùy model/script.

### 19.2. Netlist transient mẫu

```spice
* inverter transient test
.include "models.spice"

VDD vdd 0 1.8
VIN in 0 pulse(0 1.8 0 10p 10p 5n 10n)

XINV in out vdd 0 inv
CLOAD out 0 10f

.tran 1p 50n
.control
run
plot v(in) v(out)
.endc
.end
```

Chạy:

```bash
ngspice inverter_tb.spice
```

Batch mode:

```bash
ngspice -b -o sim.log inverter_tb.spice
```

### 19.3. Phân tích DC operating point

```spice
.op
.control
run
print all
.endc
```

### 19.4. AC analysis

```spice
.ac dec 100 1 1G
.control
run
plot db(v(out)/v(in))
.endc
```

### 19.5. Kỹ năng thành thạo

- Đọc operating point transistor.
- Kiểm tra bias region.
- Đo propagation delay.
- Đo gain/bandwidth/phase margin.
- Chạy corner bằng `.include` model khác nhau.
- Xuất raw/waveform.

---

## 20. Xyce — circuit simulator cho mạch lớn hơn

### 20.1. Vai trò

Xyce là simulator SPICE-like có thể mạnh hơn cho một số bài toán lớn/parallel.

### 20.2. Lệnh cơ bản

```bash
Xyce circuit.sp
```

Batch log:

```bash
Xyce -l xyce.log circuit.sp
```

### 20.3. Khi nào dùng Xyce?

- Mạch analog lớn.
- Post-layout netlist nhiều parasitic.
- Muốn thử simulator khác để so sánh ngspice.

---

# PHẦN G — MEMORY / MACRO

---

## 21. OpenRAM — SRAM compiler

### 21.1. Vai trò

OpenRAM tạo SRAM macro và các view phục vụ ASIC flow:

- layout.
- SPICE/netlist.
- Liberty timing/power.
- LEF.
- GDS.
- Verilog model.

### 21.2. Config OpenRAM mẫu

`openram_config.py`:

```python
word_size = 32
num_words = 256
num_banks = 1

tech_name = "sky130"
process_corners = ["TT"]
supply_voltages = [1.8]
temperatures = [25]

output_path = "./sram_out"
output_name = "sram_256x32"
```

### 21.3. Chạy OpenRAM

```bash
python3 $OPENRAM_HOME/../sram_compiler.py openram_config.py
```

### 21.4. Tích hợp SRAM vào digital flow

Bạn cần đưa vào flow:

- `.lef` cho placement/routing.
- `.lib` cho timing.
- `.v` behavioral/blackbox cho synthesis/simulation.
- `.gds` để merge GDS cuối.

### 21.5. Lỗi thường gặp

| Lỗi | Cách xử lý |
|---|---|
| Không tìm thấy tech | kiểm tra `OPENRAM_HOME`, `OPENRAM_TECH` |
| Macro quá lớn | giảm word/words hoặc tăng die area |
| Timing fail qua SRAM | thêm pipeline hoặc nới clock |
| LVS fail | kiểm tra pin order/name, GDS merge |

---

# PHẦN H — IP MANAGEMENT

---

## 22. FuseSoC + Edalize

### 22.1. Vai trò

FuseSoC quản lý IP core, file list, parameter, target simulation/synthesis. Edalize là lớp backend để gọi tool như Icarus, Verilator, GHDL, Yosys.

### 22.2. Core file mẫu

`my_counter.core`:

```yaml
CAPI=2:
name: local:example:counter:0.1.0
filesets:
  rtl:
    files:
      - rtl/counter.v
    file_type: verilogSource
  tb:
    files:
      - sim/counter_tb.v
    file_type: verilogSource

targets:
  sim:
    filesets:
      - rtl
      - tb
    toplevel: counter_tb
    default_tool: icarus
    tools:
      icarus: {}
```

Chạy:

```bash
fusesoc run --target=sim local:example:counter
```

### 22.3. Khi nào nên dùng?

Dùng khi project có:

- nhiều IP.
- nhiều target simulation/synthesis.
- cần tái sử dụng block.
- muốn quản lý dependency sạch hơn Makefile thuần.

---

# PHẦN I — PDK VÀ FILE FORMAT

---

## 23. PDK — thứ quan trọng nhất sau tool

### 23.1. PDK chứa gì?

| File/thành phần | Vai trò |
|---|---|
| `.lib` | timing/power model standard cell |
| `.lef` | abstract layout cho P&R |
| `.gds` | layout thật của cell/macro |
| `.spice` | transistor-level netlist/model |
| tech LEF | layer/routing rule |
| DRC deck | luật kiểm tra layout |
| LVS setup | luật so sánh netlist/layout |
| Magic tech | công nghệ cho Magic |
| KLayout layer map | layer mapping cho GDS |

### 23.2. Các PDK trong stack

| PDK | Node | Dùng cho |
|---|---|---|
| SKY130 | 130 nm CMOS | digital/analog open-source phổ biến |
| GF180MCU | 180 nm | MCU, analog/mixed-signal |
| IHP SG13G2 | 130 nm BiCMOS | analog/RF/mixed-signal nghiên cứu |

### 23.3. Đổi PDK

```bash
source /usr/local/bin/eda-env sky130A
source /usr/local/bin/eda-env gf180mcuD
source /usr/local/bin/eda-env ihp-sg13g2
```

Kiểm tra:

```bash
echo $PDK_ROOT
echo $PDK
echo $PDKPATH
```

---

## 24. File format bắt buộc phải hiểu

| File | Ý nghĩa |
|---|---|
| `.v`, `.sv` | RTL/netlist Verilog/SystemVerilog |
| `.vhd` | VHDL |
| `.sdc` | timing constraints |
| `.lib` | Liberty timing/power |
| `.lef` | Library Exchange Format, abstract physical view |
| `.def` | Design Exchange Format, placement/routing result |
| `.gds` | layout mask data cuối |
| `.spef` | parasitic extraction |
| `.sdf` | delay annotation |
| `.spice`, `.cir`, `.cdl` | circuit netlist |
| `.mag` | Magic layout |
| `.odb` | OpenDB database của OpenROAD |
| `.vcd`, `.fst` | waveform |
| `.lyrdb` | KLayout marker database |

---

# PHẦN J — WORKFLOW MẪU HOÀN CHỈNH

---

## 25. Workflow digital IP nhỏ

```bash
# 1. Lint
verilator --lint-only -Wall -sv rtl/top.sv

# 2. Simulation
iverilog -g2012 -o build/top_tb.vvp rtl/top.sv sim/top_tb.sv
vvp build/top_tb.vvp

# 3. Waveform
gtkwave dump.vcd

# 4. Synthesis
yosys -p "read_verilog -sv rtl/top.sv; synth -top top; stat; write_verilog build/top_synth.v"

# 5. STA sơ bộ
sta sta/run_sta.tcl
```

---

## 26. Workflow SoC RTL → GDS

```text
1. RTL lint clean
2. cocotb regression pass
3. SymbiYosys formal pass cho block quan trọng
4. Yosys synthesis pass
5. OpenLane/OpenROAD P&R
6. OpenSTA timing report
7. KLayout/Magic DRC
8. Netgen LVS
9. Final GDS review
```

Checklist báo cáo:

```text
[ ] RTL commit hash
[ ] Tool version
[ ] PDK version
[ ] Clock period
[ ] Cell count
[ ] Core area
[ ] Utilization
[ ] WNS/TNS
[ ] DRC count
[ ] LVS result
[ ] GDS path
```

---

## 27. Workflow analog block

```text
1. Xschem schematic
2. ngspice pre-layout simulation
3. Magic/KLayout layout
4. Magic DRC
5. Magic extraction
6. Netgen LVS
7. ngspice post-layout simulation
8. Export GDS
```

Checklist:

```text
[ ] DC operating point đúng
[ ] transient đúng
[ ] AC/noise nếu cần
[ ] DRC clean
[ ] LVS clean
[ ] post-layout simulation không lệch quá mức
[ ] pin name khớp top integration
```

---

## 28. Workflow mixed-signal top

```text
Digital block:
RTL → OpenLane/OpenROAD → DEF/GDS/netlist

Analog block:
Xschem/Virtuoso-like flow → Magic/KLayout → GDS/SPICE

Top integration:
KLayout/Magic/OpenROAD/Virtuoso tùy flow
→ merge GDS
→ top-level LVS
→ top-level DRC
```

Nguyên tắc:

- Digital và analog phải thống nhất pin/power domain.
- Không để tên `VDD`, `vdd`, `VPWR`, `vccd1` lẫn lộn.
- Cần level shifter nếu khác voltage domain.
- Cần guard ring/decap nếu analog nhạy nhiễu.
- Cần floorplan tách analog/digital hợp lý.

---

# PHẦN K — DEBUG THEO TRIỆU CHỨNG

---

## 29. Nếu simulation pass nhưng synthesis fail

Nguyên nhân thường gặp:

- RTL dùng construct không synthesizable.
- Testbench file bị đưa nhầm vào synthesis.
- `initial`, delay, force/release, dynamic array.
- SystemVerilog feature Yosys không hỗ trợ.

Cách xử lý:

```bash
verilator --lint-only -Wall -sv rtl/top.sv
yosys -p "read_verilog -sv rtl/top.sv; hierarchy -check -top top"
```

---

## 30. Nếu synthesis pass nhưng OpenLane fail

Kiểm tra:

- `CLOCK_PORT` đúng chưa?
- `CLOCK_PERIOD` hợp lý chưa?
- `DESIGN_NAME` đúng top module chưa?
- có blackbox macro thiếu LEF/LIB/GDS không?
- die area quá nhỏ không?
- utilization quá cao không?

---

## 31. Nếu routing fail

Cách xử lý theo thứ tự:

1. Giảm `FP_CORE_UTIL`.
2. Giảm `PL_TARGET_DENSITY`.
3. Tăng die area.
4. Kiểm tra pin placement.
5. Thêm macro halo/channel nếu có SRAM.
6. Kiểm tra số layer routing.

---

## 32. Nếu timing fail

Phân loại trước:

```text
setup fail → path quá chậm
hold fail  → path quá nhanh hoặc clock skew
```

Setup fail:

- pipeline RTL.
- giảm logic giữa 2 FF.
- tăng clock period.
- giảm fanout.
- optimize placement.

Hold fail:

- chạy hold repair.
- buffer data path.
- kiểm tra constraint clock.

---

## 33. Nếu DRC fail

- Mở GDS bằng KLayout.
- Load marker database nếu có.
- Xác định layer/rule.
- Nếu là routing DRC: giảm density/tăng die.
- Nếu là macro boundary: kiểm tra obstruction/halo.
- Nếu là seal ring/pad: kiểm tra integration.

---

## 34. Nếu LVS fail

Thứ tự debug:

1. So top cell name.
2. So pin name/order.
3. So power/ground net.
4. So số transistor/instance.
5. Tìm open/short.
6. Kiểm tra extraction option.
7. Flatten nếu hierarchy gây nhiễu.

---

# PHẦN L — MAKEFILE MẪU

---

## 35. Makefile project nhỏ

```makefile
TOP = top
RTL = rtl/top.sv
TB  = sim/top_tb.sv
BUILD = build

.PHONY: all lint sim wave synth clean

all: lint sim synth

$(BUILD):
	mkdir -p $(BUILD)

lint:
	verilator --lint-only -Wall -sv $(RTL)

sim: $(BUILD)
	iverilog -g2012 -o $(BUILD)/$(TOP)_tb.vvp $(RTL) $(TB)
	vvp $(BUILD)/$(TOP)_tb.vvp

wave:
	gtkwave dump.vcd

synth: $(BUILD)
	yosys -p "read_verilog -sv $(RTL); synth -top $(TOP); stat; write_verilog $(BUILD)/$(TOP)_synth.v"

clean:
	rm -rf $(BUILD) *.vcd
```

---

# PHẦN M — BÀI TẬP

---

## 36. Cơ bản

### RTL sạch

- Viết counter, PWM, UART baud generator.
- Lint bằng Verilator.
- Simulation bằng Icarus.

### Testbench

- Viết HDL testbench.
- Sinh VCD.
- Debug bằng GTKWave.

### cocotb

- Test ALU bằng Python golden model.
- Random test FIFO.
- Regression nhiều seed.

### formal

- Assertion cho FIFO.
- Cover state FSM.
- Debug counterexample.

### Yosys

- Viết script synthesis.
- Đọc cell count.
- Sửa latch/multiple driver.

### STA/SDC

- Viết SDC.
- Chạy OpenSTA.
- Đọc setup/hold report.

### OpenLane/OpenROAD

- Chạy RTL → GDS cho counter/UART.
- Thử thay utilization/die area.
- So sánh QoR.

### Layout/DRC/LVS

- Mở GDS bằng KLayout.
- Chạy Magic DRC.
- Chạy Netgen LVS nếu có setup.

### Analog

- Vẽ inverter/current mirror bằng Xschem.
- Mô phỏng ngspice.
- Layout bằng Magic/KLayout nếu có PDK setup.

### SRAM

- Tạo SRAM nhỏ bằng OpenRAM.
- Kiểm tra LEF/LIB/GDS/Verilog view.

### Mini tapeout package

- Tạo report cuối:
  - RTL.
  - netlist.
  - GDS.
  - timing.
  - DRC/LVS.
  - README.

## 37. Nguồn tham khảo

- Verilator User Guide: https://verilator.org/guide/latest/
- cocotb Documentation: https://docs.cocotb.org/
- Yosys Documentation: https://yosys.readthedocs.io/
- OpenROAD Documentation: https://openroad.readthedocs.io/
- OpenLane 2 Documentation: https://openlane2.readthedocs.io/
- OpenSTA GitHub/Docs: https://github.com/The-OpenROAD-Project/OpenSTA
- KLayout Documentation: https://www.klayout.de/doc.html
- ngspice Documentation: https://ngspice.sourceforge.io/docs.html
- OpenRAM: https://openram.org/
- Magic VLSI: http://opencircuitdesign.com/magic/
