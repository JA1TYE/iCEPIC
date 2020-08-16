`ifndef ICEPIC_SIM_LIB_PKG
`define ICEPIC_SIM_LIB_PKG

package icepic_sim_lib_pkg;

    parameter TEST_ADDWF  = 12'h1c0;
    parameter TEST_ANDWF  = 12'h140;
    parameter TEST_CLRF   = 12'h060;
    parameter TEST_CLRW   = 12'h040;
    parameter TEST_COMF   = 12'h240;
    parameter TEST_DECF   = 12'h0c0;
    parameter TEST_DECFSZ = 12'h2c0;
    parameter TEST_INCF   = 12'h280;
    parameter TEST_INCFSZ = 12'h3c0;
    parameter TEST_IORWF  = 12'h100;
    parameter TEST_MOVF   = 12'h200;
    parameter TEST_MOVWF  = 12'h020;
    parameter TEST_NOP    = 12'h000;
    parameter TEST_RLF    = 12'h340;
    parameter TEST_RRF    = 12'h300;
    parameter TEST_SUBWF  = 12'h080;
    parameter TEST_SWAPF  = 12'h380;
    parameter TEST_XORWF  = 12'h180;
    parameter TEST_BCF    = 12'h400;
    parameter TEST_BSF    = 12'h500;
    parameter TEST_BTFSC  = 12'h600;
    parameter TEST_BTFSS  = 12'h700;
    parameter TEST_ANDLW  = 12'he00;
    parameter TEST_CALL   = 12'h900;
    //parameter TEST_CLRWDT = 12'h004;
    parameter TEST_GOTO   = 12'ha00;
    parameter TEST_IORLW  = 12'hd00;
    parameter TEST_MOVLW  = 12'hc00;
    //parameter TEST_OPTION = 12'h002;
    parameter TEST_RETLW  = 12'h800;
    //parameter TEST_SLEEP  = 12'h003;
    //parameter TEST_TRIS   = 12'h000;
    parameter TEST_XORLW  = 12'hf00;
    
    function logic[11:0] byte_set_operand(
        input logic[11:0]   inst_proto,
        input logic dest,
        input logic[4:0]    fsr_addr
    );
    begin
        byte_set_operand = inst_proto | (dest << 5) | fsr_addr;
    end
    endfunction

    function logic[11:0] bit_set_operand(
        input logic[11:0]   inst_proto,
        input logic[2:0]    bit_pos,
        input logic[4:0]    fsr_addr
    );
    begin
        bit_set_operand = inst_proto | (bit_pos << 5) | fsr_addr;
    end
    endfunction

    function logic[11:0] literal_set_operand(
        input logic[11:0]   inst_proto,
        input logic[7:0]    literal
    );
    begin
        literal_set_operand = inst_proto | literal;
    end
    endfunction

    function logic[11:0] goto_set_operand(
        input logic[11:0]   inst_proto,
        input logic[8:0]    literal
    );
    begin
        goto_set_operand = inst_proto | literal;
    end
    endfunction

endpackage

`endif