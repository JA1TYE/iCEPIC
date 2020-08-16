module alu
	import icepic_lib_pkg::*;
(
    input   logic[7:0]  a_in,
    input   logic[7:0]  b_in,
    input   alu_op_t    alu_op_in,
    input   logic[2:0]  bit_pos_in,
    input   status_t    status_in,
    output  logic[7:0]  result_out,
    output  logic       skip_flag_out,
    output  logic       status_update_out,
    output  status_t    status_out
);

logic[7:0]  a_in_temp;
logic[7:0]  adder_temp;
logic       dc_temp;
logic       c_temp;
logic       zero_check;

assign zero_check   = (result_out == 8'h0);
assign a_in_temp    = a_in_select(a_in,alu_op_in);

adder Adder(.a_in(a_in_temp),.b_in,.y_out(adder_temp),
            .carry_out(c_temp),.digit_carry_out(dc_temp));

//Generate skip flag
always_comb begin
    if(alu_op_in == ALU_DECFSZ || alu_op_in == ALU_INCFSZ)begin
        skip_flag_out = zero_check;
    end
    else if(alu_op_in == ALU_BIT_BTFSS)begin
        skip_flag_out = b_in[bit_pos_in];
    end
    else if(alu_op_in == ALU_BIT_BTFSC)begin
        skip_flag_out = ~b_in[bit_pos_in];
    end
    else begin
        skip_flag_out = 1'b0;
    end
end

//Prepare aliases of status wires
status_t status_check_zero;
status_t status_check_all;
always_comb begin
    status_check_zero.zero_flag = zero_check;    
    status_check_zero.dc_flag   = status_in.dc_flag;
    status_check_zero.c_flag    = status_in.c_flag;

    status_check_all.zero_flag = zero_check;
    status_check_all.dc_flag = dc_temp;
    status_check_all.c_flag = c_temp;
end

//Arithmetic operations
always_comb begin
    case(alu_op_in)
        ALU_NOP:begin
            result_out = a_in_temp;
            status_out = status_in;
            status_update_out = 1'b0;
        end        
        ALU_CLR:begin
            result_out = a_in_temp;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end
        ALU_SUB:begin
            result_out = adder_temp;
            status_out = status_check_all;
            status_update_out = 1'b1;
        end
        ALU_DEC:begin
            result_out = adder_temp;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end      
        ALU_OR:begin
            result_out = a_in_temp | b_in;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end
        ALU_AND:begin
            result_out = a_in_temp & b_in;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end
        ALU_XOR:begin
            result_out = a_in_temp ^ b_in;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end        
        ALU_ADD:begin
            result_out = adder_temp;
            status_out = status_check_all;
            status_update_out = 1'b1;
        end
        ALU_MOVF:begin
            result_out = b_in;
            status_out = status_check_zero;
            status_update_out = 1'b1;
        end
        ALU_COMF:begin
            result_out = ~b_in;
            status_out = status_check_zero;
            status_update_out = 1'b1;        
        end
        ALU_INC:begin
            result_out = adder_temp;
            status_out = status_check_zero;
            status_update_out = 1'b1;           
        end
        ALU_DECFSZ:begin
            result_out = adder_temp;
            status_out = status_in;
            status_update_out = 1'b0;
        end
        ALU_RR:begin
            result_out = {status_in.c_flag,b_in[7:1]};
            status_out.zero_flag    = status_in.zero_flag;
            status_out.dc_flag      = status_in.dc_flag;
            status_out.c_flag       = b_in[0];
            status_update_out = 1'b1;         
        end
        ALU_RL:begin
            result_out = {b_in[6:0],status_in.c_flag};
            status_out.zero_flag    = status_in.zero_flag;
            status_out.dc_flag      = status_in.dc_flag;
            status_out.c_flag       = b_in[7];
            status_update_out = 1'b1;              
        end
        ALU_SWAP:begin
            result_out = {b_in[3:0],b_in[7:4]};
            status_out = status_in;
            status_update_out = 1'b0;        
        end
        ALU_INCFSZ:begin
            result_out = adder_temp;
            status_out = status_in;
            status_update_out = 1'b0; 
        end
        ALU_BIT_SET:begin
            result_out = (b_in|(8'h01 << bit_pos_in));
            status_out = status_in;
            status_update_out = 1'b0;          
        end
        ALU_BIT_CLEAR:begin
            result_out = (b_in&(~(8'h01 << bit_pos_in)));
            status_out = status_in;
            status_update_out = 1'b0;             
        end
        default:begin
            result_out = a_in_temp;
            status_out = status_in;
            status_update_out = 1'b0;
        end
    endcase
end

//Input selector for a_in
function logic[7:0] a_in_select(input [7:0] a_in,input alu_op_t op);
begin
    case(op)
        ALU_CLR:    a_in_select = 8'h00;
        ALU_DEC:    a_in_select = ~(8'h01) + 1;
        ALU_DECFSZ: a_in_select = ~(8'h01) + 1;
        ALU_INC:    a_in_select = 8'h01;
        ALU_INCFSZ: a_in_select = 8'h01;
        ALU_SUB:    a_in_select = ~(a_in) + 1;
        default:    a_in_select = a_in;
    endcase
end
endfunction

endmodule

//8-bit adder with carry/digit_carry output
module adder(
    input   logic[7:0]  a_in,
    input   logic[7:0]  b_in,
    output  logic[7:0]  y_out,
    output  logic       carry_out,
    output  logic       digit_carry_out
);
    logic[4:0]  lower;
    logic[4:0]  higher;
    assign lower = {1'b0,a_in[3:0]} + {1'b0,b_in[3:0]};
    assign digit_carry_out = lower[4];
    assign higher = {1'b0,a_in[7:4]} + {1'b0,b_in[7:4]} + lower[4];
    assign y_out = {higher[3:0],lower[3:0]};
    assign carry_out = higher[4];

endmodule