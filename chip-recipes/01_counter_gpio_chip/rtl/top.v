module top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] gpio_in,
    output wire [7:0] gpio_out
);
    reg [23:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 24'd0;
        else
            counter <= counter + 24'd1;
    end

    assign gpio_out = counter[23:16] ^ {4'b0000, gpio_in};
endmodule
