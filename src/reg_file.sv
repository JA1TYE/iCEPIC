module reg_file
	import icepic_lib_pkg::*;
    (
        input   logic[7:0]      addr_in,
        input   logic           write_en_in,   
        input   logic[7:0]      d_in,
        input   status_t        status_in,
        input   logic           status_update_in,
        input   logic           clk_in,
        input   logic           reset_in,
        output  logic[7:0]      d_out,
        output  status_t        status_out,
        output  logic[1:0]      page_out,
        output  logic[7:0]      gpio_out
    );

    parameter mem_addr_width  =   4;
    parameter mem_deep        =   (1 << mem_addr_width) - 1;

    reg[7:0]    mem[mem_deep:0];
    logic[7:0]  fsr;
    logic[7:0]  addr;

    assign fsr          = mem[4];
    assign addr         = (addr_in == 8'h00)?fsr:addr_in;
    assign d_out        = mem[addr]; 
    assign status_out   = status_t'(mem[3][2:0]);
    assign page_out     = mem[3][6:5];
    assign gpio_out     = mem[6];

    always@(posedge clk_in)begin
        if(reset_in == 1'b1)begin
            mem[3]  <= 8'b00011000;
            mem[4]  <= 8'h0;
        end
        else begin
            if(write_en_in == 1'b1)begin
                //STATUS
                if(addr == 8'h03 && status_update_in == 1'b1)begin
                    mem[8'h03] <= {d_in[7:5],2'b11,status_in};
                end
                else begin
                    mem[8'h03] <= {mem[8'h03][7:5],2'b11,status_in};
                    mem[addr] <= d_in;
                end
            end
            else begin
                mem[8'h03] <= {mem[8'h03][7:5],2'b11,status_in};
            end
        end
    end

endmodule