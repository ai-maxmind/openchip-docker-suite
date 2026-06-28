module crc32_serial (
    input wire clk,
    input wire rst_n,
    input wire init,
    input wire enable,
    input wire data_bit,
    output reg [31:0] crc
);
    wire feedback = crc[31] ^ data_bit;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) crc <= 32'hFFFF_FFFF;
        else if (init) crc <= 32'hFFFF_FFFF;
        else if (enable) begin
            crc <= {crc[30:0],1'b0} ^ (feedback ? 32'h04C11DB7 : 32'h00000000);
        end
    end
endmodule
