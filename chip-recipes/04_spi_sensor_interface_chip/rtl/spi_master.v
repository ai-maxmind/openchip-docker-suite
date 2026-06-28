module spi_master #(
    parameter DIV = 4
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,
    output reg        sclk,
    output reg        mosi,
    output reg        cs_n,
    output reg [7:0]  rx_data,
    output reg        done,
    output reg        busy
);
    reg [7:0] shifter;
    reg [2:0] bit_cnt;
    reg [15:0] div_cnt;
    reg phase;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk <= 0; mosi <= 0; cs_n <= 1; rx_data <= 0; done <= 0; busy <= 0;
            shifter <= 0; bit_cnt <= 0; div_cnt <= 0; phase <= 0;
        end else begin
            done <= 0;
            if (!busy) begin
                sclk <= 0; cs_n <= 1;
                if (start) begin
                    busy <= 1; cs_n <= 0; shifter <= tx_data; bit_cnt <= 3'd7; mosi <= tx_data[7]; div_cnt <= 0; phase <= 0;
                end
            end else begin
                if (div_cnt == DIV-1) begin
                    div_cnt <= 0; sclk <= ~sclk; phase <= ~phase;
                    if (!phase) begin
                        rx_data <= {rx_data[6:0], miso};
                    end else begin
                        if (bit_cnt == 0) begin busy <= 0; cs_n <= 1; done <= 1; sclk <= 0; end
                        else begin bit_cnt <= bit_cnt - 1'b1; shifter <= {shifter[6:0],1'b0}; mosi <= shifter[6]; end
                    end
                end else div_cnt <= div_cnt + 1'b1;
            end
        end
    end
endmodule
