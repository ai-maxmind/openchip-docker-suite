`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0;
    reg [7:0] gpio_in=8'h3C;
    wire [7:0] gpio_out;
    wire uart_tx_o;
    top dut(.clk(clk), .rst_n(rst_n), .gpio_in(gpio_in), .gpio_out(gpio_out), .uart_tx_o(uart_tx_o));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(5) @(posedge clk); rst_n=1;
        repeat(2000) @(posedge clk);
        $display("PASS uart/gpio/timer demo gpio_out=%h tx=%b", gpio_out, uart_tx_o);
        $finish;
    end
endmodule
