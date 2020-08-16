module inst_dec
	import icepic_lib_pkg::*;
(
    input   logic[1:0]      page_in,
    input   inst_t          inst_in,
    output  alu_op_t        alu_op_out,
    output  logic[11:0]     jump_addr_out,
    output  pc_update_sel_t pc_update_sel_out,
    output  alu_b_sel_t     alu_b_sel_out,
    output  logic           f_write_en_out,
    output  logic           w_write_en_out,
    output  logic           stack_pop_out,
    output  logic           stack_push_out
);

inst_type_t inst_type;
alu_dest_sel_t dest_sel;
logic   write_en;

assign f_write_en_out   = (dest_sel == ALU_DEST_SEL_F && write_en == 1'b1);
assign w_write_en_out   = (dest_sel == ALU_DEST_SEL_W && write_en == 1'b1);

//decide instruction type
always_comb begin
    if(inst_in.inst[11:10] == 2'b00)begin
        inst_type = BYTE_INST_TYPE;
    end
    else if(inst_in.inst[11:10] == 2'b01)begin
        inst_type = BIT_INST_TYPE;
    end
    else if(inst_in.inst[11:9] == 3'b101)begin
        inst_type = GOTO_INST_TYPE;
    end
    else begin
        inst_type = LITERAL_INST_TYPE;
    end
end

//generate signal for destination selection
always_comb begin
    if(inst_type == BYTE_INST_TYPE)begin
        dest_sel = (inst_in.BYTE_INST.dest == 1'b0)?ALU_DEST_SEL_W:ALU_DEST_SEL_F;
    end
    else if(inst_type == BIT_INST_TYPE)begin
        dest_sel = ALU_DEST_SEL_F;
    end
    else begin
        dest_sel = ALU_DEST_SEL_W;
    end
end

//generate destination write enable signal
always_comb begin
    //NOP,CLRWDT,OPTION,SLEEP,TRIS
    if(inst_in.inst == 12'h00x)begin
        write_en = 1'b0;
    end
    else if(inst_type == BIT_INST_TYPE &&
            (alu_op_out == ALU_BIT_BTFSC || alu_op_out == ALU_BIT_BTFSS))begin
        write_en = 1'b0;            
    end
    //CALL
    else if(inst_type == LITERAL_INST_TYPE && inst_in.LITERAL_INST.opcode == 4'b1001)begin
        write_en = 1'b0;
    end
    //GOTO
    else if(inst_type == GOTO_INST_TYPE)begin
        write_en = 1'b0;
    end    
    else begin
        write_en = 1'b1;
    end
end

//generate stack push/pop signal
always_comb begin
    if(inst_type == LITERAL_INST_TYPE)begin
        //CALL
        if(inst_in.LITERAL_INST.opcode == 4'b1001)begin
            stack_pop_out   = 1'b0;
            stack_push_out  = 1'b1;
        end
        //RETLW
        else if(inst_in.LITERAL_INST.opcode == 4'b1000)begin
            stack_pop_out   = 1'b1;
            stack_push_out  = 1'b0;
        end
        else begin
            stack_pop_out   = 1'b0;
            stack_push_out  = 1'b0;
        end
    end
    else begin
        stack_pop_out   = 1'b0;
        stack_push_out  = 1'b0; 
    end
end

//generate signal for ALU B input selection
always_comb begin
    if(inst_type == BYTE_INST_TYPE || inst_type == BIT_INST_TYPE)begin
        alu_b_sel_out = ALU_B_SEL_FILE; 
    end
    else begin
        alu_b_sel_out = ALU_B_SEL_LITERAL;
    end
end

//generate pc update source selection signal
always_comb begin
    //CALL
    if(inst_type == LITERAL_INST_TYPE && inst_in.LITERAL_INST.opcode == 4'b1001)begin
        pc_update_sel_out = PC_UPDATE_JUMP;
    end
    //RETLW
    else if(inst_type == LITERAL_INST_TYPE && inst_in.LITERAL_INST.opcode == 4'b1000)begin
        pc_update_sel_out = PC_UPDATE_RET;
    end
    //GOTO
    else if(inst_type == GOTO_INST_TYPE)begin
        pc_update_sel_out = PC_UPDATE_JUMP;
    end
    else if(inst_type == BYTE_INST_TYPE && inst_in.BYTE_INST.addr == SFR_PCL)begin
        pc_update_sel_out = (dest_sel == ALU_DEST_SEL_F)?PC_UPDATE_PCL_MOD:PC_UPDATE_INC;
    end
    else if(inst_type == BIT_INST_TYPE && inst_in.BIT_INST.addr == SFR_PCL)begin
        pc_update_sel_out = PC_UPDATE_PCL_MOD;
    end
    else begin
        pc_update_sel_out = PC_UPDATE_INC;
    end
end

//calculate jump address
always_comb begin
    if(inst_type == GOTO_INST_TYPE)begin
        jump_addr_out = {1'b0,page_in,inst_in.GOTO_INST.addr};
    end
    else if(inst_type == LITERAL_INST_TYPE)begin
        jump_addr_out = {1'b0,page_in,1'b0,inst_in.LITERAL_INST.literal};
    end
    else begin
        jump_addr_out = 12'hxxx;
    end
end

//generate ALU opcode
always_comb begin
    if(inst_type == BYTE_INST_TYPE)begin
        alu_op_out = alu_op_t'(inst_in.BYTE_INST.opcode[4:0]);
    end
    else if(inst_type == BIT_INST_TYPE)begin
        alu_op_out = alu_op_t'(({1'b1,inst_in.BIT_INST.opcode[1:0],2'h0}));
    end
    else if(inst_type == LITERAL_INST_TYPE)begin
        //ANDLW
        if(inst_in.LITERAL_INST.opcode == 4'b1110)begin
            alu_op_out = ALU_AND;
        end
        //IORLW
        else if(inst_in.LITERAL_INST.opcode == 4'b1101)begin
            alu_op_out = ALU_OR;
        end
        //MOVLW
        else if(inst_in.LITERAL_INST.opcode == 4'b1100)begin
            alu_op_out = ALU_MOVF;
        end
        //RETLW
        else if(inst_in.LITERAL_INST.opcode == 4'b1000)begin
            alu_op_out = ALU_MOVF;
        end
        //XORLW
        else if(inst_in.LITERAL_INST.opcode == 4'b1111)begin
            alu_op_out = ALU_XOR;
        end
        else begin
            alu_op_out = ALU_NOP;
        end    
    end
    else begin
        alu_op_out = ALU_NOP;
    end
end

endmodule