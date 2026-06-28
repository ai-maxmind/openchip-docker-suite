`timescale 1ns/1ps

module counter_tb;
    reg clk = 0;
    reg rst_n = 0;
    wire [7:0] count;

    counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/counter.vcd");
        $dumpvars(0, counter_tb);

        #20;
        rst_n = 1;

        #100;

        if (count == 0) begin
            $display("FAIL: counter did not increment");
            $finish(1);
        end

        $display("PASS: count=%0d", count);
        $finish(0);
    end
endmodule
