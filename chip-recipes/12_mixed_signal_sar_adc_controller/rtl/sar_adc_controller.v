module sar_adc_controller #(
    parameter N = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire comp_gt,
    output reg sample,
    output reg dac_update,
    output reg done,
    output reg [N-1:0] dac_code,
    output reg [N-1:0] result
);
    localparam IDLE=0, SAMPLE=1, TRIAL=2, DECIDE=3, DONE=4;
    reg [2:0] state;
    reg [3:0] bit_idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; sample <= 0; dac_update <= 0; done <= 0; dac_code <= 0; result <= 0; bit_idx <= 0;
        end else begin
            sample <= 0; dac_update <= 0; done <= 0;
            case(state)
            IDLE: begin
                if (start) begin result <= 0; dac_code <= 0; bit_idx <= N-1; state <= SAMPLE; end
            end
            SAMPLE: begin
                sample <= 1; state <= TRIAL;
            end
            TRIAL: begin
                dac_code <= result | ({{(N-1){1'b0}},1'b1} << bit_idx);
                dac_update <= 1;
                state <= DECIDE;
            end
            DECIDE: begin
                if (comp_gt) result <= dac_code;
                if (bit_idx == 0) state <= DONE;
                else begin bit_idx <= bit_idx - 1'b1; state <= TRIAL; end
            end
            DONE: begin done <= 1; state <= IDLE; end
            endcase
        end
    end
endmodule
