module i2c_master_simple #(
    parameter DIV = 16
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [6:0] addr,
    input wire [7:0] data,
    output reg scl,
    output reg sda_o,
    output reg sda_oe,
    input wire sda_i,
    output reg done,
    output reg busy
);
    localparam IDLE=0, START=1, BITS=2, ACK=3, STOP1=4, STOP2=5;
    reg [2:0] state;
    reg [15:0] div_cnt;
    reg [3:0] bit_cnt;
    reg [15:0] frame;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl <= 1; sda_o <= 1; sda_oe <= 1; done <= 0; busy <= 0; state <= IDLE; div_cnt <= 0; bit_cnt <= 0; frame <= 0;
        end else begin
            done <= 0;
            if (div_cnt != DIV-1) div_cnt <= div_cnt + 1'b1;
            else begin
                div_cnt <= 0;
                case (state)
                IDLE: begin
                    scl <= 1; sda_o <= 1; sda_oe <= 1; busy <= 0;
                    if (start) begin busy <= 1; frame <= {addr,1'b0,data}; bit_cnt <= 4'd15; state <= START; end
                end
                START: begin sda_o <= 0; scl <= 1; state <= BITS; end
                BITS: begin
                    scl <= ~scl;
                    if (scl == 0) begin sda_oe <= 1; sda_o <= frame[bit_cnt]; end
                    else begin if (bit_cnt == 0) state <= ACK; else bit_cnt <= bit_cnt - 1'b1; end
                end
                ACK: begin
                    scl <= ~scl;
                    if (scl == 0) sda_oe <= 0;
                    else state <= STOP1;
                end
                STOP1: begin sda_oe <= 1; sda_o <= 0; scl <= 1; state <= STOP2; end
                STOP2: begin sda_o <= 1; done <= 1; busy <= 0; state <= IDLE; end
                endcase
            end
        end
    end
endmodule
