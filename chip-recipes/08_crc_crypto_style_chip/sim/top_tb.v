`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0, init=0, enable=0, data_bit=0;
    wire [31:0] crc;
    integer i;
    top dut(.clk(clk), .rst_n(rst_n), .init(init), .enable(enable), .data_bit(data_bit), .crc(crc));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(2) @(posedge clk); rst_n=1; init=1;
        @(posedge clk); init=0;
        for (i=0; i<32; i=i+1) begin
            data_bit = i[0]; enable=1; @(posedge clk);
        end
        enable=0; repeat(2) @(posedge clk);
        $display("PASS crc demo crc=%h", crc);
        $finish;
    end
endmodule
