`timescale 1ns/1ps
module cpu_test();
    import icepic_lib_pkg::*;
    logic clk_in;
    logic reset_in;

    icepic_12 DUT(.clk_in,.reset_in);

    initial begin
        clk_in      <= 0;
        reset_in    <= 1;
        repeat(10)@(posedge clk_in);
        reset_in    <= 0;
    end

    always begin
        #1 clk_in <= ~clk_in;
    end

endmodule