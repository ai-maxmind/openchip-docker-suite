`timescale 1ns/1ps
module top_tb;
    reg clk = 0;
    reg rst_n = 0;
    reg [3:0] gpio_in = 4'h5;
    wire [7:0] gpio_out;

    top dut (.clk(clk), .rst_n(rst_n), .gpio_in(gpio_in), .gpio_out(gpio_out));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/top.vcd");
        $dumpvars(0, top_tb);
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (100) @(posedge clk);
        gpio_in = 4'hA;
        repeat (100) @(posedge clk);
        $display("PASS counter/gpio demo gpio_out=%h", gpio_out);
        $finish;
    end
endmodule
