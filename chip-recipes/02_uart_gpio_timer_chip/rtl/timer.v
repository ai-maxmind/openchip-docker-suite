module timer #(
    parameter WIDTH = 24
)(
    input  wire clk,
    input  wire rst_n,
    input  wire enable,
    input  wire [WIDTH-1:0] compare,
    output reg tick
);
    reg [WIDTH-1:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0; tick <= 0;
        end else begin
            tick <= 0;
            if (enable) begin
                if (count == compare) begin count <= 0; tick <= 1; end
                else count <= count + 1;
            end
        end
    end
endmodule
