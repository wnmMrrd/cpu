`include "defines.v"

module IF(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus] pc_i,
    output reg[`InstAddrBus] pc_o,
    output reg[`InstBus] inst_o,

    input wire inst_done,
    input wire[`InstBus] inst_i,
    input wire[`InstAddrBus] inst_pc,
    output wire inst_req,
    output reg[31:0] inst_addr,

    output reg if_stall
);

    reg [31:0] icache[127:0];
    reg [8:0] tag[127:0];
    assign inst_req = (tag[inst_addr[8:2]] != inst_addr[17:9]) & (inst_done == `False_v);

    integer i;

    always @ (posedge clk) begin
        if(rst) begin
            for (i=0; i<128; i++) begin
                tag[i][8] <= 1'b1;
            end
            inst_addr <= `ZeroWord;
        end else if(inst_done == `True_v) begin
            icache[inst_pc[8:2]] <= inst_i;
            tag[inst_pc[8:2]] <= inst_pc[17:9];
            inst_addr <= pc_i+4;
        end else begin
            inst_addr <= pc_i;
        end
    end

    always @ (*) begin
        if(rst) begin
            pc_o= `ZeroWord;
            inst_o = `ZeroWord;
            if_stall = `False_v;
        end else if(tag[pc_i[8:2]] == pc_i[17:9]) begin
            pc_o = pc_i;
            inst_o = icache[pc_i[8:2]];
            if_stall = `False_v;
        end else begin
            pc_o= `ZeroWord;
            inst_o = `ZeroWord;
            if_stall = `True_v;
        end
    end

endmodule