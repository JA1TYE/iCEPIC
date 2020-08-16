module stack
	import icepic_lib_pkg::*;
    (
        input   logic[11:0]     stack_in,
        input   logic           push_in,
        input   logic           pop_in,
        input   logic           clk_in,
        input   logic           reset_in,
        output  logic[11:0]     stack_out
    );

    parameter stack_addr_width  =   1;
    parameter stack_deep        =   (1 << stack_addr_width) - 1;

    logic[11:0]                       stack[stack_deep:0];
    logic[stack_addr_width - 1:0]     top_of_stack;

    assign stack_out    = stack[(top_of_stack == 0)?0:top_of_stack - 1];

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            top_of_stack    <= 0;
        end
        else begin
            if(push_in == 1'b1)begin
                stack[top_of_stack] <= stack_in;
                top_of_stack <= (top_of_stack == stack_deep)?stack_deep:top_of_stack + 1;
            end
            else if(pop_in == 1'b1)begin
                top_of_stack <= (top_of_stack == 0)?0:top_of_stack - 1;
            end            
        end
    end

endmodule
