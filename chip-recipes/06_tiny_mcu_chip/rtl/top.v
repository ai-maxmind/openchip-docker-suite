module top (
    input wire clk,
    input wire rst_n,
    output wire [7:0] gpio_out
);
    wire [7:0] addr;
    wire [15:0] rdata;
    wire [15:0] wdata;
    wire we;

    tiny_cpu u_cpu(.clk(clk), .rst_n(rst_n), .mem_addr(addr), .mem_rdata(rdata), .mem_wdata(wdata), .mem_we(we), .gpio_out(gpio_out));
    rom_ram u_mem(.clk(clk), .addr(addr), .rdata(rdata), .wdata(wdata), .we(we));
endmodule
