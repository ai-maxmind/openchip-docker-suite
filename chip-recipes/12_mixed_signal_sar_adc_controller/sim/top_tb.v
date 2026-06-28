`timescale 1ns/1ps
module top_tb;
    reg clk=0, rst_n=0, start=0;
    reg comp_gt=0;
    wire sample, dac_update, done;
    wire [7:0] dac_code, result;
    localparam [7:0] ANALOG_INPUT_CODE = 8'd153;

    top dut(.clk(clk), .rst_n(rst_n), .start(start), .comp_gt(comp_gt), .sample(sample), .dac_update(dac_update), .done(done), .dac_code(dac_code), .result(result));
    always #5 clk=~clk;

    always @(*) begin
        comp_gt = (ANALOG_INPUT_CODE >= dac_code);
    end

    initial begin
        $dumpfile("build/top.vcd"); $dumpvars(0, top_tb);
        repeat(3) @(posedge clk); rst_n=1;
        @(posedge clk); start=1; @(posedge clk); start=0;
        wait(done); repeat(2) @(posedge clk);
        $display("PASS SAR ADC controller result=%0d", result);
        $finish;
    end
endmodule
