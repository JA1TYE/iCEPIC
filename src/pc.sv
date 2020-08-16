module pc
	import icepic_lib_pkg::*;
    (
        input   logic[11:0]     pcl_mod_in,
        input   logic[11:0]     jump_addr_in,
        input   logic[11:0]     stack_addr_in,
        input   pc_update_sel_t pc_sel_in,
        input   logic           clk_in,
        input   logic           reset_in,
        output  logic[11:0]     pc_out
    );

    assign pc_out = program_counter;

    logic[11:0] program_counter;

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            program_counter <= 12'h000;
        end
        else begin
            case(pc_sel_in)
                PC_UPDATE_INC:      program_counter <= program_counter + 1;
                PC_UPDATE_JUMP:     program_counter <= jump_addr_in;
                PC_UPDATE_RET:      program_counter <= stack_addr_in;
                PC_UPDATE_PCL_MOD:  program_counter <= pcl_mod_in;
            endcase
        end
    end

endmodule
