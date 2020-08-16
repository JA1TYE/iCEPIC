`timescale 1ns/1ps
module inst_dec_test();
    import icepic_lib_pkg::*;    
    import icepic_sim_lib_pkg::*;
    logic[1:0]      page_in;
    inst_t          inst_in;
    alu_op_t        alu_op_out;
    logic[4:0]      fsr_addr_out;
    logic[2:0]      bit_pos_out;
    logic[7:0]      literal_out;
    logic[10:0]     jump_addr_out;
    pc_update_sel_t pc_update_sel_out;
    alu_b_sel_t     alu_b_sel_out;
    logic           f_write_en_out;
    logic           w_write_en_out;
    logic           stack_pop_out;
    logic           stack_push_out;

    inst_dec DUT(.*);

    task test_alu_op(input logic [11:0]inst,input alu_op_t exp_val,int line);
        import icepic_lib_pkg::*; 
        inst_in <= (inst_t'(inst));
        #1;										 						   
        if(alu_op_out !== exp_val)$display("Test failed. value:%d,expected:%d at line %d", alu_op_out, exp_val,line);
    endtask

    initial begin
        page_in <= 2'h0;

        //BYTE oriented instructions
        //ADDWF
        test_alu_op(byte_set_operand(TEST_ADDWF,1'b0,5'h0),ALU_ADD,`__LINE__);
        test_alu_op(byte_set_operand(TEST_ADDWF,1'b1,5'h0),ALU_ADD,`__LINE__);
        test_alu_op(byte_set_operand(TEST_ADDWF,1'b1,5'h1),ALU_ADD,`__LINE__);

        //ANDWF
        test_alu_op(byte_set_operand(TEST_ANDWF,1'b0,5'h0),ALU_AND,`__LINE__);
        test_alu_op(byte_set_operand(TEST_ANDWF,1'b1,5'h0),ALU_AND,`__LINE__);
        test_alu_op(byte_set_operand(TEST_ANDWF,1'b1,5'h1),ALU_AND,`__LINE__);

        //CLRF
        test_alu_op(byte_set_operand(TEST_CLRF,1'b0,5'h0),ALU_CLR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_CLRF,1'b0,5'h1),ALU_CLR,`__LINE__);

        //CLRW
        test_alu_op(byte_set_operand(TEST_CLRW,1'b0,5'h0),ALU_CLR,`__LINE__);
        
        //COMF
        test_alu_op(byte_set_operand(TEST_COMF,1'b0,5'h0),ALU_COMF,`__LINE__);
        test_alu_op(byte_set_operand(TEST_COMF,1'b1,5'h0),ALU_COMF,`__LINE__);
        test_alu_op(byte_set_operand(TEST_COMF,1'b1,5'h1),ALU_COMF,`__LINE__);

        //DECF
        test_alu_op(byte_set_operand(TEST_DECF,1'b0,5'h0),ALU_DEC,`__LINE__);
        test_alu_op(byte_set_operand(TEST_DECF,1'b1,5'h0),ALU_DEC,`__LINE__);
        test_alu_op(byte_set_operand(TEST_DECF,1'b1,5'h1),ALU_DEC,`__LINE__);

        //DECFSZ
        test_alu_op(byte_set_operand(TEST_DECFSZ,1'b0,5'h0),ALU_DECFSZ,`__LINE__);
        test_alu_op(byte_set_operand(TEST_DECFSZ,1'b1,5'h0),ALU_DECFSZ,`__LINE__);
        test_alu_op(byte_set_operand(TEST_DECFSZ,1'b1,5'h1),ALU_DECFSZ,`__LINE__);

        //INCF
        test_alu_op(byte_set_operand(TEST_INCF,1'b0,5'h0),ALU_INC,`__LINE__);
        test_alu_op(byte_set_operand(TEST_INCF,1'b1,5'h0),ALU_INC,`__LINE__);
        test_alu_op(byte_set_operand(TEST_INCF,1'b1,5'h1),ALU_INC,`__LINE__);

        //INCFSZ
        test_alu_op(byte_set_operand(TEST_INCFSZ,1'b0,5'h0),ALU_INCFSZ,`__LINE__);
        test_alu_op(byte_set_operand(TEST_INCFSZ,1'b1,5'h0),ALU_INCFSZ,`__LINE__);
        test_alu_op(byte_set_operand(TEST_INCFSZ,1'b1,5'h1),ALU_INCFSZ,`__LINE__);

        //IORWF
        test_alu_op(byte_set_operand(TEST_IORWF,1'b0,5'h0),ALU_OR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_IORWF,1'b1,5'h0),ALU_OR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_IORWF,1'b1,5'h1),ALU_OR,`__LINE__);

        //MOVF
        test_alu_op(byte_set_operand(TEST_MOVF,1'b0,5'h0),ALU_MOVF,`__LINE__);
        test_alu_op(byte_set_operand(TEST_MOVF,1'b1,5'h0),ALU_MOVF,`__LINE__);
        test_alu_op(byte_set_operand(TEST_MOVF,1'b1,5'h1),ALU_MOVF,`__LINE__);

        //MOVWF
        test_alu_op(byte_set_operand(TEST_MOVWF,1'b0,5'h0),ALU_NOP,`__LINE__);
        test_alu_op(byte_set_operand(TEST_MOVWF,1'b0,5'h1),ALU_NOP,`__LINE__);

        //NOP
        test_alu_op(byte_set_operand(TEST_NOP,1'b0,5'h0),ALU_NOP,`__LINE__);

        //RLF
        test_alu_op(byte_set_operand(TEST_RLF,1'b0,5'h0),ALU_RL,`__LINE__);
        test_alu_op(byte_set_operand(TEST_RLF,1'b1,5'h0),ALU_RL,`__LINE__);
        test_alu_op(byte_set_operand(TEST_RLF,1'b1,5'h1),ALU_RL,`__LINE__);

        //RRF
        test_alu_op(byte_set_operand(TEST_RRF,1'b0,5'h0),ALU_RR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_RRF,1'b1,5'h0),ALU_RR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_RRF,1'b1,5'h1),ALU_RR,`__LINE__);

        //SUBWF
        test_alu_op(byte_set_operand(TEST_SUBWF,1'b0,5'h0),ALU_SUB,`__LINE__);
        test_alu_op(byte_set_operand(TEST_SUBWF,1'b1,5'h0),ALU_SUB,`__LINE__);
        test_alu_op(byte_set_operand(TEST_SUBWF,1'b1,5'h1),ALU_SUB,`__LINE__);

        //SWAPF
        test_alu_op(byte_set_operand(TEST_SWAPF,1'b0,5'h0),ALU_SWAP,`__LINE__);
        test_alu_op(byte_set_operand(TEST_SWAPF,1'b1,5'h0),ALU_SWAP,`__LINE__);
        test_alu_op(byte_set_operand(TEST_SWAPF,1'b1,5'h1),ALU_SWAP,`__LINE__);

        //XORWF
        test_alu_op(byte_set_operand(TEST_XORWF,1'b0,5'h0),ALU_XOR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_XORWF,1'b1,5'h0),ALU_XOR,`__LINE__);
        test_alu_op(byte_set_operand(TEST_XORWF,1'b1,5'h1),ALU_XOR,`__LINE__);

        //BIT oriented instructions
        //BCF
        test_alu_op(bit_set_operand(TEST_BCF,3'h0,5'h0),ALU_BIT_CLEAR,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BCF,3'h1,5'h0),ALU_BIT_CLEAR,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BCF,3'h0,5'h1),ALU_BIT_CLEAR,`__LINE__);

        //BSF
        test_alu_op(bit_set_operand(TEST_BSF,3'h0,5'h0),ALU_BIT_SET,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BSF,3'h1,5'h0),ALU_BIT_SET,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BSF,3'h0,5'h1),ALU_BIT_SET,`__LINE__);

        //BTFSC
        test_alu_op(bit_set_operand(TEST_BTFSC,3'h0,5'h0),ALU_BIT_BTFSC,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BTFSC,3'h1,5'h0),ALU_BIT_BTFSC,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BTFSC,3'h0,5'h1),ALU_BIT_BTFSC,`__LINE__);

        //BTFSS
        test_alu_op(bit_set_operand(TEST_BTFSS,3'h0,5'h0),ALU_BIT_BTFSS,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BTFSS,3'h1,5'h0),ALU_BIT_BTFSS,`__LINE__);
        test_alu_op(bit_set_operand(TEST_BTFSS,3'h0,5'h1),ALU_BIT_BTFSS,`__LINE__);

        //LITERAL instructions
        //ANDLW
        test_alu_op(literal_set_operand(TEST_ANDLW,8'h00),ALU_AND,`__LINE__);
        test_alu_op(literal_set_operand(TEST_ANDLW,8'haa),ALU_AND,`__LINE__);

        //CALL
        test_alu_op(literal_set_operand(TEST_CALL,8'h00),ALU_NOP,`__LINE__);
        test_alu_op(literal_set_operand(TEST_CALL,8'haa),ALU_NOP,`__LINE__);

        //IORLW
        test_alu_op(literal_set_operand(TEST_IORLW,8'h00),ALU_OR,`__LINE__);
        test_alu_op(literal_set_operand(TEST_IORLW,8'haa),ALU_OR,`__LINE__);

        //MOVLW
        test_alu_op(literal_set_operand(TEST_MOVLW,8'h00),ALU_MOVF,`__LINE__);
        test_alu_op(literal_set_operand(TEST_MOVLW,8'haa),ALU_MOVF,`__LINE__);

        //RETLW
        test_alu_op(literal_set_operand(TEST_RETLW,8'h00),ALU_MOVF,`__LINE__);
        test_alu_op(literal_set_operand(TEST_RETLW,8'haa),ALU_MOVF,`__LINE__);
        
        //XORLW
        test_alu_op(literal_set_operand(TEST_XORLW,8'h00),ALU_XOR,`__LINE__);
        test_alu_op(literal_set_operand(TEST_XORLW,8'haa),ALU_XOR,`__LINE__);

        //GOTO
        test_alu_op(goto_set_operand(TEST_GOTO,9'h00),ALU_NOP,`__LINE__);
        test_alu_op(goto_set_operand(TEST_GOTO,9'haa),ALU_NOP,`__LINE__);

    end

endmodule