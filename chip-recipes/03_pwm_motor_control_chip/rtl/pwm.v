module pwm #(
    parameter WIDTH = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [WIDTH-1:0] duty,
    output reg pwm_o
);
    reg [WIDTH-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin cnt <= 0; pwm_o <= 0; end
        else begin
            cnt <= cnt + 1'b1;
            pwm_o <= (cnt < duty);
        end
    end
endmodule
