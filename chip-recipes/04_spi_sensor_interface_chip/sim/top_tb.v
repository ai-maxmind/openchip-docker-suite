`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0, miso=0;
    wire sclk, mosi, cs_n, done;
    top dut(.clk(clk), .rst_n(rst_n), .miso(miso), .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .done(done));
    always #5 clk=~clk;
    always @(negedge sclk) miso <= ~miso;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(4) @(posedge clk); rst_n=1;
        wait(done); repeat(20) @(posedge clk);
        $display("PASS spi demo cs_n=%b mosi=%b", cs_n, mosi);
        $finish;
    end
endmodule
