module top (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [31:0] a_vec,
    input wire [31:0] b_vec,
    output wire [31:0] result,
    output wire done
);
    vector_mac #(.W(8), .N(4), .ACCW(32)) u_mac(
        .clk(clk), .rst_n(rst_n), .start(start), .a_vec(a_vec), .b_vec(b_vec), .result(result), .done(done)
    );
endmodule
