`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0;
    wire [7:0] gpio_out;
    top dut(.clk(clk), .rst_n(rst_n), .gpio_out(gpio_out));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(4) @(posedge clk); rst_n=1;
        repeat(60) @(posedge clk);
        $display("PASS tiny mcu demo gpio_out=%0d", gpio_out);
        $finish;
    end
endmodule
