`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0, start=0;
    reg [31:0] a_vec, b_vec;
    wire [31:0] result;
    wire done;
    top dut(.clk(clk), .rst_n(rst_n), .start(start), .a_vec(a_vec), .b_vec(b_vec), .result(result), .done(done));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        a_vec = {8'd4,8'd3,8'd2,8'd1};
        b_vec = {8'd8,8'd7,8'd6,8'd5};
        repeat(3) @(posedge clk); rst_n=1;
        @(posedge clk); start=1;
        @(posedge clk); start=0;
        repeat(4) @(posedge clk);
        if (result !== 32'd70) begin $display("FAIL result=%0d", result); $fatal; end
        $display("PASS vector mac result=%0d", result);
        $finish;
    end
endmodule
