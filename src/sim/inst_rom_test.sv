`timescale 1ns/1ps
module inst_rom_test();
	import icepic_lib_pkg::*;
    logic[11:0] addr_in;
    logic       clk_in;
    logic[15:0] d_out;

    inst_rom DUT(.*);

    initial begin
        addr_in <=  12'h000;
        clk_in  <=  1'b0;
    end

    always begin
        #1 clk_in <= ~clk_in;
    end

    always@(posedge clk_in)begin
        addr_in <= addr_in + 1;
    end

endmodule