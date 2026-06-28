module top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] duty,
    output wire       pwm_raw,
    output wire       gate_high,
    output wire       gate_low
);
    pwm u_pwm(.clk(clk), .rst_n(rst_n), .duty(duty), .pwm_o(pwm_raw));
    deadtime_halfbridge #(.DEAD(8)) u_dt(.clk(clk), .rst_n(rst_n), .pwm_in(pwm_raw), .high_o(gate_high), .low_o(gate_low));
endmodule
