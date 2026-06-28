module sram_ctrl #(
    parameter AW = 8,
    parameter DW = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    output reg done,
    output reg [DW-1:0] readback,
    output wire csb0,
    output wire web0,
    output wire [AW-1:0] addr0,
    output wire [DW-1:0] din0,
    input  wire [DW-1:0] dout0
);
    reg [2:0] state;
    reg we_n;
    reg [AW-1:0] addr;
    reg [DW-1:0] data;
    assign csb0 = (state == 0);
    assign web0 = we_n;
    assign addr0 = addr;
    assign din0 = data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state <= 0; done <= 0; readback <= 0; we_n <= 1; addr <= 0; data <= 0; end
        else begin
            done <= 0;
            case(state)
            0: if (start) begin addr <= 8'h10; data <= 32'hCAFE_BABE; we_n <= 0; state <= 1; end
            1: begin we_n <= 1; state <= 2; end
            2: begin state <= 3; end
            3: begin readback <= dout0; done <= 1; state <= 0; end
            endcase
        end
    end
endmodule
