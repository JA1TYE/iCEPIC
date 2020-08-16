`timescale 1ns/1ps
module alu_test();
    import icepic_lib_pkg::*;
    logic[7:0]  a_in;
    logic[7:0]  b_in;
    alu_op_t alu_op_in;
    logic[2:0]  bit_pos_in;
    status_t status_in;
    logic[7:0]  result_out;
    logic skip_flag_out;
    logic status_update_out;
    status_t status_out;

    alu DUT(.a_in,.b_in,.alu_op_in,.bit_pos_in,.status_in,
            .result_out,.skip_flag_out,.status_update_out,.status_out);

    task test(input logic[7:0] a,input logic[7:0] b,input logic[7:0] exp_val,int line);
        a_in <= a;
        b_in <= b;
        #1;
        if(result_out !== exp_val)$display("Test failed. value:%d,expected:%d at line %d", result_out, exp_val,line);
    endtask

    initial begin
        bit_pos_in <= 3'h0;
        status_in.zero_flag <= 1'b0;
        status_in.dc_flag   <= 1'b0;
        status_in.c_flag    <= 1'b0;

        //NOP
        alu_op_in <= ALU_NOP;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'haa,8'h00,8'haa,`__LINE__);
        test(8'haa,8'hcc,8'haa,`__LINE__);


        //CLR
        alu_op_in <= ALU_CLR;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'haa,8'h00,8'h00,`__LINE__);
        test(8'haa,8'hcc,8'h00,`__LINE__);

        //SUB
        alu_op_in <= ALU_SUB;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'h11,8'h22,8'h11,`__LINE__);
        test(8'h22,8'h11,8'hef,`__LINE__);

        //DEC
        alu_op_in <= ALU_DEC;
        test(8'h00,8'h00,8'hFF,`__LINE__);
        test(8'h11,8'h02,8'h01,`__LINE__);
        test(8'h11,8'h01,8'h00,`__LINE__);

        //OR
        alu_op_in <= ALU_OR;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'haf,8'h5f,8'hff,`__LINE__);

        //AND
        alu_op_in <= ALU_AND;
        test(8'hf0,8'h0f,8'h00,`__LINE__);
        test(8'haa,8'ha5,8'ha0,`__LINE__);

        //XOR
        alu_op_in <= ALU_XOR;
        test(8'hff,8'hff,8'h00,`__LINE__);
        test(8'haa,8'ha5,8'h0f,`__LINE__);

        //ADD
        alu_op_in <= ALU_ADD;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'h11,8'h22,8'h33,`__LINE__);
        test(8'hff,8'h02,8'h01,`__LINE__);

        //MOVF
        alu_op_in <= ALU_MOVF;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'h11,8'h22,8'h22,`__LINE__);

        //COMF
        alu_op_in <= ALU_COMF;
        test(8'h00,8'hff,8'h00,`__LINE__);
        test(8'h00,8'haa,8'h55,`__LINE__);

        //INC
        alu_op_in <= ALU_INC;
        test(8'h00,8'h00,8'h01,`__LINE__);
        test(8'h11,8'hff,8'h00,`__LINE__);
        test(8'h11,8'h01,8'h02,`__LINE__);

        //DECFSZ
        alu_op_in <= ALU_DECFSZ;
        test(8'h00,8'h00,8'hFF,`__LINE__);
        test(8'h11,8'h02,8'h01,`__LINE__);
        test(8'h11,8'h01,8'h00,`__LINE__);

        //RR
        alu_op_in <= ALU_RR;
        test(8'h00,8'hff,8'h7f,`__LINE__);
        status_in.c_flag    <= 1'b1;
        test(8'h00,8'hff,8'hff,`__LINE__);
        status_in.c_flag    <= 1'b0;

        //RL
        alu_op_in <= ALU_RL;
        test(8'h00,8'hff,8'hfe,`__LINE__);
        status_in.c_flag    <= 1'b1;
        test(8'h00,8'hff,8'hff,`__LINE__);
        status_in.c_flag    <= 1'b0;
        
        //SWAP
        alu_op_in <= ALU_SWAP;
        test(8'h00,8'h00,8'h00,`__LINE__);
        test(8'h11,8'ha5,8'h5a,`__LINE__);

        //INCFSZ
        alu_op_in <= ALU_INCFSZ;
        test(8'h00,8'h00,8'h01,`__LINE__);
        test(8'h11,8'hff,8'h00,`__LINE__);
        test(8'h11,8'h01,8'h02,`__LINE__);

        //BIT_SET
        alu_op_in <= ALU_BIT_SET;
        test(8'h00,8'h00,8'h01,`__LINE__);
        bit_pos_in <= 3'h4;
        test(8'h11,8'h01,8'h11,`__LINE__);
        test(8'h11,8'h11,8'h11,`__LINE__);
        bit_pos_in <= 3'h0;

        //BIT_CLEAR
        alu_op_in <= ALU_BIT_CLEAR;
        test(8'h00,8'h01,8'h00,`__LINE__);
        bit_pos_in <= 3'h4;
        test(8'h11,8'h11,8'h01,`__LINE__);
        test(8'h11,8'h01,8'h01,`__LINE__);
        bit_pos_in <= 3'h0;

        //BTFSC
        alu_op_in <= ALU_BIT_BTFSC;
        test(8'haa,8'h00,8'haa,`__LINE__);
        test(8'h11,8'h01,8'h11,`__LINE__);

        //BTFSS
        alu_op_in <= ALU_BIT_BTFSS;
        test(8'haa,8'h00,8'haa,`__LINE__);
        test(8'h11,8'h01,8'h11,`__LINE__);

    end

endmodule