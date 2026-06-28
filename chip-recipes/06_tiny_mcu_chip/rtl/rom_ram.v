module rom_ram (
    input wire clk,
    input wire [7:0] addr,
    output reg [15:0] rdata,
    input wire [15:0] wdata,
    input wire we
);
    reg [15:0] mem [0:255];
    integer i;
    initial begin
        for (i=0; i<256; i=i+1) mem[i] = 16'h0000;
        mem[0] = 16'h1001; // LDI 1
        mem[1] = 16'h3000; // OUT
        mem[2] = 16'h2001; // ADD 1
        mem[3] = 16'h3000; // OUT
        mem[4] = 16'h4002; // JMP 2
    end
    always @(posedge clk) begin
        if (we) mem[addr] <= wdata;
        rdata <= mem[addr];
    end
endmodule
