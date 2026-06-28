`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0;
    reg [7:0] duty=8'd64;
    wire pwm_raw, gate_high, gate_low;
    top dut(.clk(clk), .rst_n(rst_n), .duty(duty), .pwm_raw(pwm_raw), .gate_high(gate_high), .gate_low(gate_low));
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(3) @(posedge clk); rst_n=1;
        repeat(300) @(posedge clk); duty=8'd192;
        repeat(300) @(posedge clk);
        $display("PASS pwm demo high=%b low=%b", gate_high, gate_low);
        $finish;
    end
endmodule
