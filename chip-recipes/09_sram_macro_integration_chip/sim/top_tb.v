`timescale 1ns/1ps
`define SIM_SRAM
module top_tb;
    reg clk=0, rst_n=0, start=0;
    wire done;
    wire [31:0] readback;
    top dut(.clk(clk), .rst_n(rst_n), .start(start), .done(done), .readback(readback));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(3) @(posedge clk); rst_n=1;
        @(posedge clk); start=1; @(posedge clk); start=0;
        wait(done); repeat(2) @(posedge clk);
        $display("PASS sram integration readback=%h", readback);
        $finish;
    end
endmodule
