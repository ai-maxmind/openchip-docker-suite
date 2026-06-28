module top (
    input wire clk,
    input wire rst_n,
    input wire sda_i,
    output wire scl,
    output wire sda_o,
    output wire sda_oe,
    output wire done
);
    reg [15:0] timer;
    reg start;
    wire busy;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin timer <= 0; start <= 0; end
        else begin timer <= timer + 1'b1; start <= (timer == 16'd50) & ~busy; end
    end
    i2c_master_simple u_i2c(.clk(clk), .rst_n(rst_n), .start(start), .addr(7'h42), .data(8'h5A), .scl(scl), .sda_o(sda_o), .sda_oe(sda_oe), .sda_i(sda_i), .done(done), .busy(busy));
endmodule
