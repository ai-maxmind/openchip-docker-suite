module top (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire comp_gt,
    output wire sample,
    output wire dac_update,
    output wire done,
    output wire [7:0] dac_code,
    output wire [7:0] result
);
    sar_adc_controller #(.N(8)) u_sar(
        .clk(clk), .rst_n(rst_n), .start(start), .comp_gt(comp_gt),
        .sample(sample), .dac_update(dac_update), .done(done), .dac_code(dac_code), .result(result)
    );
endmodule
