module top (
    input  wire clk,
    input  wire rst_n,
    input  wire miso,
    output wire sclk,
    output wire mosi,
    output wire cs_n,
    output wire done
);
    reg [15:0] timer;
    reg start;
    wire busy;
    wire [7:0] rx_data;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin timer <= 0; start <= 0; end
        else begin
            timer <= timer + 1'b1;
            start <= (timer == 16'd100) & ~busy;
        end
    end
    spi_master u_spi(.clk(clk), .rst_n(rst_n), .start(start), .tx_data(8'hA5), .miso(miso), .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .rx_data(rx_data), .done(done), .busy(busy));
endmodule
