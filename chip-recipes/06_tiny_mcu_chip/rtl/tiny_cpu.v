module tiny_cpu (
    input  wire        clk,
    input  wire        rst_n,
    output reg  [7:0]  mem_addr,
    input  wire [15:0] mem_rdata,
    output reg  [15:0] mem_wdata,
    output reg         mem_we,
    output reg  [7:0]  gpio_out
);
    reg [7:0] pc;
    reg [15:0] acc;
    wire [3:0] op  = mem_rdata[15:12];
    wire [7:0] imm = mem_rdata[7:0];

    localparam OP_NOP=4'h0, OP_LDI=4'h1, OP_ADD=4'h2, OP_OUT=4'h3, OP_JMP=4'h4, OP_STORE=4'h5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 0; acc <= 0; mem_addr <= 0; mem_wdata <= 0; mem_we <= 0; gpio_out <= 0;
        end else begin
            mem_we <= 0;
            mem_addr <= pc;
            case (op)
            OP_NOP: pc <= pc + 1'b1;
            OP_LDI: begin acc <= {8'd0, imm}; pc <= pc + 1'b1; end
            OP_ADD: begin acc <= acc + {8'd0, imm}; pc <= pc + 1'b1; end
            OP_OUT: begin gpio_out <= acc[7:0]; pc <= pc + 1'b1; end
            OP_JMP: begin pc <= imm; end
            OP_STORE: begin mem_addr <= imm; mem_wdata <= acc; mem_we <= 1; pc <= pc + 1'b1; end
            default: pc <= pc + 1'b1;
            endcase
        end
    end
endmodule
