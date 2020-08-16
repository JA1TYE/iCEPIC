module inst_rom(
    input   logic[11:0] addr_in,
    input   logic       clk_in,
    output  logic[15:0] d_out
);
    parameter mem_width = 10;

    reg[15:0] mem[(1 << mem_width) - 1:0];

    initial begin
        $readmemh("./pic_src/program.dat",mem);
    end

    always@(posedge clk_in)begin
        d_out <= mem[addr_in];        
    end

endmodule