module top(    
    input   logic       clk_in,
    output  logic[7:0]  led
);
    
    logic[3:0]  reset_counter = 4'h0;
    logic       reset = 1'b1;

    always@(posedge clk_in)begin
        reset_counter <= reset_counter + 1;
        if(reset == 1'b1)begin
            if(reset_counter == 4'hf)reset <= 1'b0;
        end
    end


    icepic_12 CPU(.clk_in(clk_in),.reset_in(reset),.gpio_out(led));


endmodule