module uart_tx #(
    parameter CLKS_PER_BIT = 16
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] data,
    output reg        tx,
    output reg        busy
);
    localparam IDLE=0, START=1, DATA=2, STOP=3;
    reg [1:0] state;
    reg [15:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shifter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx <= 1'b1; busy <= 1'b0; clk_cnt <= 0; bit_idx <= 0; shifter <= 0;
        end else begin
            case (state)
            IDLE: begin
                tx <= 1'b1; busy <= 1'b0; clk_cnt <= 0; bit_idx <= 0;
                if (start) begin
                    busy <= 1'b1; shifter <= data; state <= START;
                end
            end
            START: begin
                tx <= 1'b0;
                if (clk_cnt == CLKS_PER_BIT-1) begin clk_cnt <= 0; state <= DATA; end
                else clk_cnt <= clk_cnt + 1;
            end
            DATA: begin
                tx <= shifter[0];
                if (clk_cnt == CLKS_PER_BIT-1) begin
                    clk_cnt <= 0; shifter <= {1'b0, shifter[7:1]};
                    if (bit_idx == 3'd7) state <= STOP; else bit_idx <= bit_idx + 1;
                end else clk_cnt <= clk_cnt + 1;
            end
            STOP: begin
                tx <= 1'b1;
                if (clk_cnt == CLKS_PER_BIT-1) begin clk_cnt <= 0; state <= IDLE; end
                else clk_cnt <= clk_cnt + 1;
            end
            endcase
        end
    end
endmodule
