module top (
    input wire clk,
    input wire rst_n,
    input wire init,
    input wire enable,
    input wire data_bit,
    output wire [31:0] crc
);
    crc32_serial u_crc(.clk(clk), .rst_n(rst_n), .init(init), .enable(enable), .data_bit(data_bit), .crc(crc));
endmodule
