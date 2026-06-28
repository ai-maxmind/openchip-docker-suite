`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0, sda_i=0;
    wire scl, sda_o, sda_oe, done;
    top dut(.clk(clk), .rst_n(rst_n), .sda_i(sda_i), .scl(scl), .sda_o(sda_o), .sda_oe(sda_oe), .done(done));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(5) @(posedge clk); rst_n=1;
        wait(done); repeat(20) @(posedge clk);
        $display("PASS i2c demo scl=%b sda_o=%b oe=%b", scl, sda_o, sda_oe);
        $finish;
    end
endmodule
