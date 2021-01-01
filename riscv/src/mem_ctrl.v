`include "defines.v"

module mem_ctrl(
	input wire clk,
	input wire rst,

	input wire inst_req_i,
	input wire[`InstAddrBus] inst_addr_i,
	output reg[`InstBus] inst_o,
	output reg[`InstAddrBus] inst_addr_o,
	output reg inst_done_o,

	input wire ram_r_req,
	input wire ram_w_req,
	input wire[31:0] ram_addr,
	output reg[31:0] ram_r_data,
	input wire[31:0] ram_w_data,
	input wire[3:0] buffer_pointer_i,
	output reg ram_done,

	input wire[7:0] mem_din,
	output reg[7:0] mem_dout,
	output reg[31:0] mem_a,
	output reg mem_wr
);

	reg[2:0] buffer_pointer;
	reg[1:0] ram_state;
	reg[31:0] ram_pos;

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			inst_o <= `ZeroWord;
			inst_addr_o <= `ZeroWord;
			inst_done_o <= `False_v;
			ram_r_data <= `ZeroWord;
			ram_done <= `False_v;
			mem_dout <= 8'b00000000;
			mem_a <= `ZeroWord;
			mem_wr <= `Read;
			buffer_pointer <= 3'h0;
			ram_state <= `Free;
			ram_pos <= `ZeroWord;
		end else if(ram_state == `Free) begin
			inst_done_o <= `False_v;
			ram_done <= `False_v;
			mem_wr <= `Read;
			if(ram_r_req == `True_v) begin
				buffer_pointer <= 3'h0;
				ram_state <= `Read;
			end else if(ram_w_req == `True_v) begin
				mem_a <= `ZeroWord;
				if(ram_addr[17:16] != 2'b11)
					buffer_pointer <= buffer_pointer_i;
				else
					buffer_pointer <= 3'h3;
				ram_state <= `Write;
			end else if(inst_req_i) begin
				mem_a <= inst_addr_i;
				buffer_pointer <= 3'h0;
				ram_state <= `IF;
				ram_pos <= inst_addr_i;
			end
		end else if(ram_state == `Read && ram_r_req == `True_v) begin
			inst_done_o = `False_v;
			ram_done <= `False_v;
			case(buffer_pointer)
				3'h0:begin
					mem_a <= ram_addr;
					mem_wr <= `Read;
					buffer_pointer <= 3'h1;
				end
				3'h1:begin
					mem_a <= ram_addr+1;
					mem_wr <= `Read;
					buffer_pointer <= 3'h2;
				end
				3'h2:begin
					ram_r_data[7:0] <= mem_din;
					mem_a <= ram_addr+2;
					mem_wr <= `Read;
					buffer_pointer <= 3'h3;
				end
				3'h3:begin
					ram_r_data[15:8] <= mem_din;
					mem_a <= ram_addr+3;
					mem_wr <= `Read;
					buffer_pointer <= 3'h4;
				end
				3'h4:begin
					ram_r_data[23:16] <= mem_din;
					buffer_pointer <= 3'h5;
				end
				3'h5:begin
					ram_r_data[31:24] <= mem_din;
					ram_done <= `True_v;
					buffer_pointer <= 3'h0;
					ram_state <= `Free;
				end
			endcase
		end else if(ram_state == `Write && ram_w_req == `True_v) begin
			inst_done_o = `False_v;
			ram_done <= `False_v;
			case(buffer_pointer)
				3'h0:begin
					mem_dout <= ram_w_data[31:24];
					mem_a <= ram_addr+3;
					mem_wr <= `Write;
					buffer_pointer <= 3'h1;
				end
				3'h1:begin
					mem_dout <= ram_w_data[23:16];
					mem_a <= ram_addr+2;
					mem_wr <= `Write;
					buffer_pointer <= 3'h2;
				end
				3'h2:begin
					mem_dout <= ram_w_data[15:8];
					mem_a <= ram_addr+1;
					mem_wr <= `Write;
					buffer_pointer <= 3'h3;
				end
				3'h3:begin
					mem_dout <= ram_w_data[7:0];
					mem_a <= ram_addr;
					mem_wr <= `Write;
					ram_done <= `True_v;
					buffer_pointer <= 3'h0;
					ram_state <= `Free;
				end
			endcase
		end else if(ram_state == `IF && inst_req_i == `True_v) begin
			inst_done_o = `False_v;
			ram_done <= `False_v;
			if(inst_addr_i != ram_pos) begin
				mem_wr <= `Read;
				mem_a <= inst_addr_i;
				buffer_pointer <= 3'h0;
				ram_pos <= inst_addr_i;
			end else begin
				case(buffer_pointer)
					3'h0:begin
						mem_a <= ram_pos+1;
						mem_wr <= `Read;
						buffer_pointer <= 3'h1;
					end
					3'h1:begin
						inst_o[7:0] <= mem_din;
						mem_a <= ram_pos+2;
						mem_wr <= `Read;
						buffer_pointer <= 3'h2;
					end
					3'h2:begin
						inst_o[15:8] <= mem_din;
						mem_a <= ram_pos+3;
						mem_wr <= `Read;
						buffer_pointer <= 3'h3;
					end
					3'h3:begin
						inst_o[23:16] <= mem_din;
						buffer_pointer <= 3'h4;
					end
					3'h4:begin
						inst_o[31:24] <= mem_din;
						buffer_pointer <= 3'h0;
						inst_done_o <= `True_v;
						inst_addr_o <= ram_pos;
						ram_state <= `Free;
					end
				endcase
			end
		end else begin
			inst_done_o = `False_v;
			ram_done <= `False_v;
			mem_wr <= `Read;
			ram_state <= `Free;
		end
	end

endmodule