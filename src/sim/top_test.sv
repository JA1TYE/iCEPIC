`timescale 1ns/1ps
module top_test();
    logic clk_in;
    logic[7:0] led;

    top DUT(.clk_in,.led);

    initial begin
        clk_in      <= 0;
    end

    always begin
        #1 clk_in <= ~clk_in;
    end

endmodule