// Replace this blackbox with an OpenRAM-generated SRAM macro.
// Use -DSIM_SRAM for behavioral simulation. For synthesis, this is a blackbox.

`ifdef SIM_SRAM
module sram_1rw_blackbox #(
    parameter AW = 8,
    parameter DW = 32
)(
    input  wire clk0,
    input  wire csb0,
    input  wire web0,
    input  wire [AW-1:0] addr0,
    input  wire [DW-1:0] din0,
    output reg  [DW-1:0] dout0
);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    always @(posedge clk0) begin
        if (!csb0) begin
            if (!web0) mem[addr0] <= din0;
            dout0 <= mem[addr0];
        end
    end
endmodule
`else
(* blackbox *)
module sram_1rw_blackbox #(
    parameter AW = 8,
    parameter DW = 32
)(
    input  wire clk0,
    input  wire csb0,
    input  wire web0,
    input  wire [AW-1:0] addr0,
    input  wire [DW-1:0] din0,
    output wire [DW-1:0] dout0
);
endmodule
`endif
