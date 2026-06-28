module top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] gpio_in,
    output wire [7:0] gpio_out,
    output wire       uart_tx_o
);
    wire tick;
    reg [7:0] tx_data;
    reg start;
    wire busy;

    timer #(.WIDTH(12)) u_timer (
        .clk(clk), .rst_n(rst_n), .enable(1'b1), .compare(12'd100), .tick(tick)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data <= 8'h41; start <= 1'b0;
        end else begin
            start <= tick & ~busy;
            if (tick & ~busy) tx_data <= tx_data + 1'b1;
        end
    end

    uart_tx #(.CLKS_PER_BIT(8)) u_uart (
        .clk(clk), .rst_n(rst_n), .start(start), .data(tx_data), .tx(uart_tx_o), .busy(busy)
    );

    assign gpio_out = gpio_in ^ tx_data;
endmodule
