`ifndef ICEPIC_LIB_PKG
`define ICEPIC_LIB_PKG

package icepic_lib_pkg;

    parameter SFR_PCL       = 2;
    parameter SFR_STATUS    = 3;

    typedef union packed {
        logic[11:0] inst;
        struct packed {logic[5:0] opcode; logic dest; logic[4:0] addr;} BYTE_INST;
        struct packed {logic[3:0] opcode; logic[2:0] pos; logic[4:0] addr;} BIT_INST;
        struct packed {logic[3:0] opcode; logic[7:0] literal;} LITERAL_INST;
        struct packed {logic[2:0] opcode; logic[8:0] addr;} GOTO_INST;
    } inst_t;

    typedef enum logic[1:0] {
        BYTE_INST_TYPE,
        BIT_INST_TYPE,
        LITERAL_INST_TYPE,
        GOTO_INST_TYPE
    } inst_type_t;

    typedef enum logic {
        ALU_B_SEL_FILE = 1'b0,
        ALU_B_SEL_LITERAL = 1'b1
    }alu_b_sel_t;

    typedef enum logic {
        ALU_DEST_SEL_W = 1'b0,
        ALU_DEST_SEL_F = 1'b1
    }alu_dest_sel_t;

    typedef enum logic[1:0] {
        PC_UPDATE_INC       = 2'h0,
        PC_UPDATE_JUMP      = 2'h1,
        PC_UPDATE_RET       = 2'h2,
        PC_UPDATE_PCL_MOD   = 2'h3
    }pc_update_sel_t;

    typedef struct packed{logic zero_flag;
                          logic dc_flag; logic c_flag;}status_t;

    typedef enum logic[4:0] {
        ALU_NOP         = 5'h00,
        ALU_CLR         = 5'h01,
        ALU_SUB         = 5'h02,
        ALU_DEC         = 5'h03,
        ALU_OR          = 5'h04,
        ALU_AND         = 5'h05,
        ALU_XOR         = 5'h06,
        ALU_ADD         = 5'h07,
        ALU_MOVF        = 5'h08,
        ALU_COMF        = 5'h09,
        ALU_INC         = 5'h0a,
        ALU_DECFSZ      = 5'h0b,
        ALU_RR          = 5'h0c,
        ALU_RL          = 5'h0d,
        ALU_SWAP        = 5'h0e,
        ALU_INCFSZ      = 5'h0f,
        ALU_BIT_CLEAR   = 5'h10,
        ALU_BIT_SET     = 5'h14,
        ALU_BIT_BTFSC   = 5'h18,
        ALU_BIT_BTFSS   = 5'h1c
    } alu_op_t;

endpackage

`endif