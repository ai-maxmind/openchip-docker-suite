module top (
    input wire clk,
    input wire rst_n,
    input wire start,
    output wire done,
    output wire [31:0] readback
);
    wire csb0, web0;
    wire [7:0] addr0;
    wire [31:0] din0, dout0;
    sram_ctrl u_ctrl(.clk(clk), .rst_n(rst_n), .start(start), .done(done), .readback(readback), .csb0(csb0), .web0(web0), .addr0(addr0), .din0(din0), .dout0(dout0));
    sram_1rw_blackbox u_sram(.clk0(clk), .csb0(csb0), .web0(web0), .addr0(addr0), .din0(din0), .dout0(dout0));
endmodule
