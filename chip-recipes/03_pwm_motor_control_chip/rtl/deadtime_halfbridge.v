module deadtime_halfbridge #(
    parameter DEAD = 4
)(
    input wire clk,
    input wire rst_n,
    input wire pwm_in,
    output reg high_o,
    output reg low_o
);
    reg pwm_d;
    reg [7:0] dead_cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_d <= 0; dead_cnt <= 0; high_o <= 0; low_o <= 0;
        end else begin
            if (pwm_in != pwm_d) begin
                pwm_d <= pwm_in; dead_cnt <= DEAD; high_o <= 0; low_o <= 0;
            end else if (dead_cnt != 0) begin
                dead_cnt <= dead_cnt - 1'b1; high_o <= 0; low_o <= 0;
            end else begin
                high_o <= pwm_d; low_o <= ~pwm_d;
            end
        end
    end
endmodule
