module icepic_12
	import icepic_lib_pkg::*;
(
	input	logic		clk_in,
	input	logic		reset_in,
	output	logic[7:0]	gpio_out
);

//Instruction Fetch Stage wire
logic[11:0]		inst_addr;

//Instruction Fetch Stage output
logic[11:0]		d_out;
inst_t			inst_fetch;
logic[11:0]		pc_fetch;

//Instruction Decode Stage wire
alu_op_t 		alu_op_out;
alu_b_sel_t		alu_b_sel_out;
logic[11:0]		jump_addr_out;
pc_update_sel_t pc_update_sel_out;
logic			f_write_en_out;
logic			w_write_en_out;
logic			stack_pop_out;
logic			stack_push_out;
//Instruction Decode Stage output
inst_t			inst_decode;
alu_op_t 		alu_op_decode;
alu_b_sel_t		alu_b_sel_decode;
logic[11:0]		jump_addr_decode;
pc_update_sel_t pc_update_sel_decode;
logic			f_write_en_decode;
logic			w_write_en_decode;
logic			stack_pop_decode;
logic			stack_push_decode;
logic[11:0]		pc_decode;

//File register in/out
logic[7:0]	reg_out;
status_t		status_result;
status_t		status_alu_in;

//Execution Stage wire
logic[7:0]	b_in;
logic[7:0]		alu_result;
logic			status_update;
logic			skip_flag;
pc_update_sel_t	pc_update_sel_old;
logic			invalidate_op;
logic[1:0]		page;

//W Register
logic[7:0]	w_reg;

//Stack wire
logic[11:0]		stack_result;

//Intstruction Fetch Stage
inst_rom IROM(.clk_in,.addr_in(inst_addr),.d_out(d_out));
assign	inst_fetch = inst_t'(d_out);

always@(posedge clk_in)begin
	if(reset_in == 1'b1)begin
		pc_fetch <= 12'h000;
	end
	else begin
		pc_fetch <= inst_addr;
	end
end

//Instruction Decode Stage
inst_dec DECODER(.page_in(page),.inst_in(inst_fetch),
				 .alu_op_out,.alu_b_sel_out,
				 .jump_addr_out,.pc_update_sel_out,
				 .f_write_en_out,.w_write_en_out,
				 .stack_pop_out,.stack_push_out
				);

always@(posedge clk_in)begin
	if(reset_in == 1'b1)begin
		inst_decode 			<= inst_t'(12'h000);
		alu_op_decode 			<= ALU_NOP;
		alu_b_sel_decode		<= ALU_B_SEL_FILE;
		jump_addr_decode		<= 12'h000;
		pc_update_sel_decode	<= PC_UPDATE_INC;
		f_write_en_decode		<= 1'b0;
		w_write_en_decode		<= 1'b0;
		stack_pop_decode		<= 1'b0;
		stack_push_decode		<= 1'b0;
		pc_decode				<= 12'h000;	
	end
	else begin
		if(invalidate_op == 1'b1)begin
			inst_decode 			<= inst_t'(12'h000);
			alu_op_decode 			<= ALU_NOP;
			alu_b_sel_decode		<= alu_b_sel_out;
			jump_addr_decode		<= jump_addr_out;
			pc_update_sel_decode	<= PC_UPDATE_INC;
			f_write_en_decode		<= 1'b0;
			w_write_en_decode		<= 1'b0;
			stack_pop_decode		<= 1'b0;
			stack_push_decode		<= 1'b0;
			pc_decode				<= pc_fetch;				
		end
		else begin
			inst_decode 			<= inst_fetch;
			alu_op_decode 			<= alu_op_out;
			alu_b_sel_decode		<= alu_b_sel_out;
			jump_addr_decode		<= jump_addr_out;
			pc_update_sel_decode	<= pc_update_sel_out;
			f_write_en_decode		<= f_write_en_out;
			w_write_en_decode		<= w_write_en_out;
			stack_pop_decode		<= stack_pop_out;
			stack_push_decode		<= stack_push_out;
			pc_decode				<= pc_fetch;		
		end
	end
end

//File register
reg_file REG_FILE(.addr_in({3'b00,inst_decode.BYTE_INST.addr}),.write_en_in(f_write_en_decode),
				  .d_in(alu_result),.d_out(reg_out),
				  .status_in(status_result),.status_update_in(status_update),.status_out(status_alu_in),
				  .page_out(page),
				  .gpio_out,
				  .clk_in,.reset_in
				 );

//Branch signals
assign 		b_in = (alu_b_sel_decode == ALU_B_SEL_FILE)?reg_out:inst_decode.LITERAL_INST.literal;
assign		invalidate_op = (skip_flag ||
							 pc_update_sel_decode != PC_UPDATE_INC ||
							 pc_update_sel_old != PC_UPDATE_INC);

always@(posedge clk_in)begin
	if(reset_in == 1'b1)begin
		pc_update_sel_old <= PC_UPDATE_INC;
	end
	else begin
		pc_update_sel_old <= pc_update_sel_decode;
	end	
end

//Execution Stage
alu ALU(.a_in(w_reg),.b_in,.alu_op_in(alu_op_decode),.bit_pos_in(inst_decode.BIT_INST.pos),
		.result_out(alu_result),.skip_flag_out(skip_flag),
		.status_in(status_alu_in),.status_update_out(status_update),.status_out(status_result));

//Writeback Stage
always@(posedge clk_in)begin
	if(reset_in == 1'b1)begin
		w_reg <= 8'h00;
	end
	else begin
		if(w_write_en_decode == 1'b1)begin
			w_reg <= alu_result;
		end
	end
end

stack	Stack(	.stack_in(pc_decode + 12'h1),.stack_out(stack_result),
				.push_in(stack_push_decode),.pop_in(stack_pop_decode),
				.clk_in,.reset_in
			);

//PC update
pc	PC(	.pcl_mod_in({1'b0,page,1'b0,alu_result}),.jump_addr_in(jump_addr_decode),
		.stack_addr_in(stack_result),
		.pc_sel_in(pc_update_sel_decode),
		.pc_out(inst_addr),
		.clk_in,.reset_in);

endmodule