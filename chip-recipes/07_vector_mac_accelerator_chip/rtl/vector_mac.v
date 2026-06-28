module vector_mac #(
    parameter W = 8,
    parameter N = 4,
    parameter ACCW = 32
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [N*W-1:0] a_vec,
    input wire [N*W-1:0] b_vec,
    output reg [ACCW-1:0] result,
    output reg done
);
    integer i;
    reg [ACCW-1:0] acc;
    always @(*) begin
        acc = 0;
        for (i=0; i<N; i=i+1) begin
            acc = acc + a_vec[i*W +: W] * b_vec[i*W +: W];
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin result <= 0; done <= 0; end
        else begin
            done <= 0;
            if (start) begin result <= acc; done <= 1; end
        end
    end
endmodule
